/* SYNTHETIC CPU probes. No natural launch, flash write or disk save. */
#include <mgba/flags.h>
#include <mgba/core/core.h>
#include <mgba/core/config.h>
#include <mgba/core/version.h>
#include <mgba/internal/gb/gb.h>
#include <mgba/internal/sm83/sm83.h>
#include <stdio.h>
#include <stdlib.h>
static unsigned checks;
static void require(int ok,const char *name,unsigned index){
 if(!ok){fprintf(stderr,"FAIL %s case=%u\n",name,index);exit(10);}checks++;
}
static void wr(struct mCore *c,unsigned address,unsigned value){c->busWrite8(c,address,value);}
static unsigned rd(struct mCore *c,unsigned address){return c->busRead8(c,address);}
static void call(struct mCore *c,unsigned entry){
 struct GB *g=c->board;struct SM83Core *cpu=g->cpu;
 wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;
 cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
 wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=entry;
 unsigned steps=0;while(cpu->pc!=0xC100&&steps++<100000)c->step(c);
 require(cpu->pc==0xC100&&cpu->sp==0xD000,"bounded return",entry);
}
int main(int argc,char **argv){
 if(argc!=2)return 2;
 struct mCore *c=mCoreFind(argv[1]);if(!c||!c->init(c))return 3;
 mCoreInitConfig(c,"synthetic-local-storage-probe");
 if(!mCoreLoadFile(c,argv[1]))return 4;
 c->reset(c);struct SM83Core *cpu=((struct GB*)c->board)->cpu;
 wr(c,0x0000,0x0A);wr(c,0x0400,0);wr(c,0x0800,1);
 /* Probe all byte indices; this does not establish directory admissibility. */
 for(unsigned index=0;index<256;index++){
  unsigned address=0xA002+6*index;
  cpu->a=index;cpu->hl=0xBEEF;call(c,0x114F);
  require(cpu->de==address&&cpu->hl==0xBEEF,"directory stride/preserve HL",index);
  unsigned pointer=0xA600+32*(index%8);
  wr(c,address,pointer&255);wr(c,address+1,pointer>>8);
  cpu->a=index;cpu->hl=0xBEED;call(c,0x1162);
  require(cpu->de==pointer&&cpu->hl==0xBEED,"header pointer/preserve HL",index);
 }
 for(unsigned status=0;status<4;status++){
  cpu->a=status;cpu->f.packed=0xB0;cpu->hl=0xD234;cpu->de=0xCAFE;
  call(c,0x1176);
  require(rd(c,0xC679)==status&&rd(c,0xC677)==0x34&&rd(c,0xC678)==0xD2,
          "result slots",status);
  require(cpu->af==((status<<8)|0xB0)&&cpu->de==0xCAFE&&cpu->hl==0xD234,
          "result register preservation",status);
 }
 /* Name match and four individual mismatch cases, using the original SYS1. */
 wr(c,0xA002,0);wr(c,0xA003,0xA4);
 wr(c,0xFF9E,0xD8);wr(c,0xFF9F,0x3E);
 for(unsigned mismatch=0;mismatch<5;mismatch++){
  for(unsigned i=0;i<4;i++)wr(c,0xA402+i,rd(c,0x3ED8+i)^((mismatch==i+1)?1:0));
  cpu->a=0;cpu->b=0;call(c,0x0F81);
  require(cpu->a==(mismatch?1:0)&&cpu->de==(mismatch?0:0xA400),
          "name match or individual mismatch",mismatch);
 }
 /* Three bounded directory states: first free, matching slot, all occupied. */
 for(unsigned mode=0;mode<3;mode++){
  for(unsigned index=0;index<130;index++){
   unsigned address=0xA002+index*6;
   wr(c,address,0);wr(c,address+1,0xA4);
   for(unsigned i=0;i<4;i++)wr(c,address+2+i,rd(c,0x3ED8+i)^1);
  }
  if(mode==0){wr(c,0xA002+3*6,0);wr(c,0xA003+3*6,0);}
  if(mode==1)for(unsigned i=0;i<4;i++)wr(c,0xA002+2*6+2+i,rd(c,0x3ED8+i));
  call(c,0x0F3E);
  require(cpu->a==mode&&cpu->b==(mode==0?3:mode==1?2:0),
          "free matching or full directory",mode);
 }
 /* One record: checksum excludes two leading checksum bytes, reads size+7. */
 wr(c,0xA002,0);wr(c,0xA003,0xA4);
 for(unsigned i=0;i<26;i++)wr(c,0xA400+i,(i*37+11)&255);
 wr(c,0xA406,17);wr(c,0xA407,0);
 unsigned expected=0;for(unsigned i=2;i<26;i++)expected+=rd(c,0xA400+i);
 cpu->a=0;call(c,0x0F15);
 require(cpu->bc==(expected&65535)&&cpu->hl==cpu->bc,"record checksum",0);
 /* Directory checksum over 130 six-byte entries; match and mismatch. */
 expected=0;for(unsigned i=0;i<0x30C;i++)expected+=rd(c,0xA002+i);
 for(unsigned mismatch=0;mismatch<2;mismatch++){
  unsigned stored=(expected+mismatch)&65535;
  wr(c,0xA000,stored&255);wr(c,0xA001,stored>>8);call(c,0x106D);
  require(cpu->de==(expected&65535)&&!!(cpu->af&0x80)==!mismatch,
          "directory checksum match or mismatch",mismatch);
 }
 const unsigned words[][2]={{0,0},{0,65535},{65535,0},{0x1200,0x12FF},
                            {0x1230,0x1200},{0x1234,0x1234},{0x1100,0x1200},{65535,65535}};
 for(unsigned i=0;i<8;i++){
  cpu->hl=words[i][0];cpu->de=words[i][1];call(c,0x200A);
  require(cpu->hl==words[i][0]&&cpu->de==words[i][1]&&
          !!(cpu->af&0x80)==(words[i][0]==words[i][1])&&
          !!(cpu->af&0x10)==(words[i][0]<words[i][1]),
          "word comparison flags and preservation",i);
 }
 /* Forced-entry open/create/close, disposable memory, not menu execution. */
 for(unsigned i=0;i<0x30E;i++)wr(c,0xA000+i,0);
 wr(c,0xFFAF,0);wr(c,0xFFB0,1);
 cpu->de=0x3ED8;cpu->bc=0x02A3;call(c,0x01B6);
 require(cpu->hl==0xA317&&rd(c,0xC677)==0x17&&rd(c,0xC678)==0xA3,
          "first-record data pointer",0);
 require(rd(c,0xA002)==0x0E&&rd(c,0xA003)==0xA3&&
          rd(c,0xA314)==0xA3&&rd(c,0xA315)==2,
          "first-record pointer and requested size",0);
 unsigned sameName=1;for(unsigned i=0;i<4;i++)sameName&=rd(c,0xA310+i)==rd(c,0x3ED8+i);
 require(sameName&&rd(c,0xA317)==0&&rd(c,0xA5B9)==0,"new name and cleared data",0);
 /* Existing open does not enforce the new requested size on this header. */
 wr(c,0xA314,2);wr(c,0xA315,0);
 cpu->de=0x3ED8;cpu->bc=0x02A3;call(c,0x01B6);
 require(cpu->hl==0xA317&&rd(c,0xA314)==2&&rd(c,0xA315)==0,
          "existing record does not resize to requested length",0);
 expected=0;for(unsigned i=2;i<11;i++)expected+=rd(c,0xA30E + i);
 call(c,0x01B9);wr(c,0x0000,0x0A);
 require((rd(c,0xA30E)|(rd(c,0xA30F)<<8))==(expected&65535),
          "close updates stored record checksum",0);
 /* Recovery: empty, one valid, invalid first, two valid, invalid second, zero sum. */
 for(unsigned mode=0;mode<6;mode++){
  for(unsigned i=0;i<4096;i++)wr(c,0xA000+i,0);
  if(mode==5){
   unsigned header=0xA30E;
   for(unsigned i=0;i<4;i++)wr(c,header+2+i,rd(c,0x3ED8+i));
   wr(c,header+6,4);wr(c,header+7,1); /* 260-byte payload */
   unsigned sum=0;for(unsigned i=2;i<9;i++)sum+=rd(c,header+i);
   unsigned remaining=65536-sum;
   for(unsigned i=0;i<260;i++){
    unsigned value=remaining>255?255:remaining;
    wr(c,header+9+i,value);remaining-=value;
   }
   require(remaining==0,"zero-sum fixture reaches modulo65536 zero",mode);
  }else if(mode){
   unsigned header=0xA30E;
   for(unsigned record=0;record<(mode>=3?2:1);record++){
    for(unsigned i=0;i<4;i++)wr(c,header+2+i,rd(c,0x3ED8+i));
    wr(c,header+6,3);wr(c,header+7,0);
    wr(c,header+8,(mode>=3&&record==0)?1:0);
    wr(c,header+9,1);wr(c,header+10,2);wr(c,header+11,3);
    unsigned checksum=0;for(unsigned i=2;i<12;i++)checksum+=rd(c,header+i);
    if(mode==2||(mode==4&&record==1))checksum++;
    wr(c,header,checksum&255);wr(c,header+1,checksum>>8);header+=12;
   }
  }
  call(c,0x108E);
  unsigned count=(mode==0||mode==2||mode==5)?0:(mode==3?2:1);
  require(cpu->a==count&&cpu->c==((mode==2||mode==4)?1:0),
          "recovery count and stop reason",mode);
  require((rd(c,0xA002)|(rd(c,0xA003)<<8))==(count?0xA30E:0),
          "recovery first pointer",mode);
  require((rd(c,0xA008)|(rd(c,0xA009)<<8))==(count==2?0xA31A:0),
          "recovery second pointer or rejected suffix",mode);
 }
 wr(c,0xA000,0xA5);wr(c,0xAFFF,0x5A);wr(c,0xB000,0x37);
 cpu->a=0;call(c,0x113E);
 unsigned cleared=1;for(unsigned i=0;i<4096;i++)cleared&=rd(c,0xA000+i)==0;
 require(cleared,"clear entire selected SRAM window",0);
 require(rd(c,0xB000)==0x37,"clear leaves other SRAM window unchanged",0);
 /* Force dispatch only; stop at JP HL target before executing target code. */
 wr(c,0x27FF,0x14);wr(c,0x2800,0);wr(c,0xFF70,1);
 const unsigned states[]={0,1,2,3,4,5,6,0x80};
 const unsigned targets[]={0x408A,0x42CD,0x42E6,0x42F9,0x4303,0x43C0,0x26CD,0xCD40};
 for(unsigned i=0;i<8;i++){
  wr(c,0xD000,states[i]);cpu->pc=0x406C;cpu->sp=0xCAFE;
  unsigned steps=0;while(cpu->pc!=targets[i]&&steps++<100)c->step(c);
  require(cpu->pc==targets[i],"state dispatch target (stop before target)",states[i]);
  require(cpu->hl==targets[i]&&cpu->sp==0xCAFE&&rd(c,0xD000)==states[i],
          "state dispatch preserves input and stack",states[i]);
 }
 /* State 1 nonzero gate: original RET path, no downstream callees. */
 for(unsigned value=1;value<256;value++){
  wr(c,0xC21F,value);cpu->bc=0x1234;cpu->de=0x5678;cpu->hl=0x9ABC;
  call(c,0x42CD);
  require(cpu->a==value&&!(cpu->af&0x80)&&rd(c,0xC21F)==value&&
          cpu->bc==0x1234&&cpu->de==0x5678&&cpu->hl==0x9ABC,
          "state 1 nonzero gate skips downstream callees",value);
 }
 /* State 4: three paths that return without external callees. */
 for(unsigned mode=0;mode<3;mode++){
  wr(c,0xD000,4);wr(c,0xD01C,mode==0?255:mode==1?1:0);
  wr(c,0xD007,5);wr(c,0xD002,3);wr(c,0xD003,8);wr(c,0xD001,2);
  wr(c,0xD020,0xA5);
  for(unsigned i=0;i<4;i++)wr(c,0xD00A+i,0xA5);
  call(c,0x4303);
  unsigned ok=rd(c,0xD000)==(mode==0?1:mode==1?2:4)&&
              rd(c,0xD020)==(mode==1?1:0xA5);
  const unsigned saved[]={2,3,5,8};
  for(unsigned i=0;i<4;i++)ok&=rd(c,0xD00A+i)==(mode==1?saved[i]:0xA5);
  require(ok,"state 4 bounded paths and saved fields",mode);
 }
 /* Two-plane copy with LCD off: data/stride only, no timing assertion. */
 wr(c,0xFF40,0);
 const unsigned widths[]={4,20,3},heights[]={1,2,3};
 for(unsigned shape=0;shape<3;shape++){
  unsigned width=widths[shape],height=heights[shape],size=width*height;
  for(unsigned i=0;i<2*size;i++)wr(c,0xD800+i,(i*37+11)&255);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);for(unsigned i=0;i<96;i++)wr(c,0x9800+i,0xA5);
  }
  wr(c,0xFF4F,1);cpu->hl=0xD800;cpu->de=0x9800;cpu->bc=(width<<8)|height;
  call(c,0x01A4);
  unsigned ok=cpu->hl==0xD800+2*size&&cpu->de==0x9800&&
              cpu->bc==((width<<8)|height)&&(rd(c,0xFF4F)&1)==1;
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned i=0;i<96;i++){
    unsigned row=i/32,col=i%32;
    unsigned expected=(row<height&&col<width)?
     ((plane*size+row*width+col)*37+11)&255:0xA5;
    ok&=rd(c,0x9800+i)==expected;
   }
  }
  require(ok,"two planes, row stride, registers and untouched padding",shape);
 }
 /* Linear copy: bounded nonzero sizes with LCD off, no timing assertion. */
 const unsigned lengths[]={1,17,32};
 for(unsigned n=0;n<3;n++){
  unsigned size=lengths[n];wr(c,0xFF4F,0);
  for(unsigned i=0;i<64;i++){
   wr(c,0xD800+i,(i*37+11)&255);wr(c,0x8000+i,0xA5);
  }
  cpu->hl=0xD800;cpu->de=0x8000;cpu->bc=size;call(c,0x0A50);
  unsigned ok=cpu->hl==0xD800+size&&cpu->de==0x8000+size&&cpu->bc==0;
  for(unsigned i=0;i<64;i++)ok&=rd(c,0x8000+i)==(i<size?((i*37+11)&255):0xA5);
  require(ok,"linear byte copy registers, data and padding",size);
 }
 /* Single-plane rectangles: DE advances one 32-byte stride per row. */
 for(unsigned shape=0;shape<3;shape++){
  unsigned width=widths[shape],height=heights[shape],size=width*height;
  for(unsigned i=0;i<size;i++)wr(c,0xD800+i,(i*37+11)&255);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);for(unsigned i=0;i<96;i++)wr(c,0x9800+i,0xA5);
  }
  wr(c,0xFF4F,1);cpu->hl=0xD800;cpu->de=0x9800;cpu->bc=(width<<8)|height;
  call(c,0x01A1);
  unsigned ok=cpu->hl==0xD800+size&&cpu->de==0x9800+height*32&&
              cpu->bc==0&&(rd(c,0xFF4F)&1)==1;
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned i=0;i<96;i++){
    unsigned row=i/32,col=i%32;
    unsigned expected=(plane==1&&row<height&&col<width)?
     ((row*width+col)*37+11)&255:0xA5;
    ok&=rd(c,0x9800+i)==expected;
   }
  }
  require(ok,"single plane rectangle and preserved other plane",shape);
 }
 /* Banked linear and two-plane copies, ROM type only, both 8KiB windows. */
 for(unsigned kind=0;kind<2;kind++)for(unsigned window=0;window<2;window++)
 for(unsigned shape=0;shape<3;shape++){
  unsigned source=window?0x6000:0x4000,select=window?0x15:0x14;
  unsigned width=widths[shape],height=heights[shape];
  unsigned size=kind?width*height:lengths[shape],total=kind?2*size:size;
  unsigned expected[192];
  wr(c,window?0x37FF:0x27FF,select);wr(c,window?0x3800:0x2800,0);
  for(unsigned i=0;i<total;i++)expected[i]=rd(c,source+i);
  wr(c,0x27FF,4);wr(c,0x2800,0);wr(c,0x37FF,5);wr(c,0x3800,0);
  wr(c,0xFFAB,4);wr(c,0xFFAC,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);
  wr(c,0xC113,4);wr(c,0xC114,0);wr(c,0xC115,5);wr(c,0xC116,0);
  unsigned oldA=rd(c,0x4000),oldB=rd(c,0x6000);
  wr(c,0xC21C,select);wr(c,0xC21D,0);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);for(unsigned i=0;i<96;i++)wr(c,(kind?0x9800:0x8000)+i,0xA5);
  }
  wr(c,0xFF4F,kind?1:0);cpu->hl=source;cpu->de=kind?0x9800:0x8000;
  cpu->bc=kind?((width<<8)|height):size;call(c,kind?0x01A7:0x019E);
  unsigned ok=cpu->hl==source+total&&cpu->de==(kind?0x9800:0x8000+size)&&
              cpu->bc==(kind?((width<<8)|height):0)&&
              (rd(c,0xFF4F)&1)==(kind?1:0)&&
              rd(c,0xFFAB)==4&&rd(c,0xFFAC)==0&&rd(c,0xFFAD)==5&&rd(c,0xFFAE)==0&&
              rd(c,0xC113)==4&&rd(c,0xC114)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0&&
              rd(c,0x4000)==oldA&&rd(c,0x6000)==oldB;
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned i=0;i<96;i++){
    unsigned row=i/32,col=i%32,value=0xA5;
    if(kind&&row<height&&col<width)value=expected[plane*size+row*width+col];
    if(!kind&&plane==0&&i<size)value=expected[i];
    ok&=rd(c,(kind?0x9800:0x8000)+i)==value;
   }
  }
  require(ok,"banked copy data, padding, registers and both mapper windows",
          kind*100+window*10+shape);
 }
 /* Forced queue body after callbacks. Positive widths/heights, LCD off. */
 wr(c,0x27FF,0x14);wr(c,0x2800,0);wr(c,0xFF70,1);
 const unsigned queueWidths[]={1,3,4,7,8,9,20,32};
 for(unsigned mode=0;mode<2;mode++)for(unsigned shape=0;shape<8;shape++){
  unsigned width=queueWidths[shape],height=2,size=width*height;
  for(unsigned i=0;i<2*size;i++)wr(c,0xD800+i,(i*37+11)&255);
  for(unsigned i=0;i<60;i++)wr(c,0xD028+i,0);
  for(unsigned slot=0;slot<10;slot++){
   wr(c,0xD028+slot*6,255);wr(c,0xD029+slot*6,255);
  }
  wr(c,0xD028,0x40);wr(c,0xD029,0x98);wr(c,0xD02A,width);
  wr(c,0xD02B,height);wr(c,0xD02C,0);wr(c,0xD02D,0xD8);
  wr(c,0xD021,mode?1:0x80);wr(c,0xD309,0);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);for(unsigned i=0;i<96;i++)wr(c,0x9840+i,0xA5);
  }
  wr(c,0xFF4F,0);call(c,0x5A0E);
  unsigned ok=rd(c,0xD021)==0&&rd(c,0xC5DA)==0&&(rd(c,0xFF4F)&1)==0;
  for(unsigned slot=0;slot<10;slot++)
   ok&=rd(c,0xD028+slot*6)==255&&rd(c,0xD029+slot*6)==255;
  ok&=rd(c,0xD02A)==width&&rd(c,0xD02B)==height&&rd(c,0xD02C)==0&&rd(c,0xD02D)==0xD8;
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned i=0;i<96;i++){
    unsigned row=i/32,col=i%32;
    unsigned expected=(row<height&&col<width&&(plane==0||mode))?
     ((plane*size+row*width+col)*37+11)&255:0xA5;
    ok&=rd(c,0x9840+i)==expected;
   }
  }
  require(ok,"queued transfer mode, row copy, consumed destinations and padding",mode*10+shape);
 }
 wr(c,0xD021,0);wr(c,0xD309,0);wr(c,0xD028,0x37);
 call(c,0x5A0E);
 require(rd(c,0xD028)==0x37&&rd(c,0xD021)==0&&rd(c,0xD309)==0,
         "inactive queue leaves descriptor unchanged",0);
 /* Actual nine-byte column read, starting in VRAM plane 1. */
 for(unsigned i=0;i<60;i++)wr(c,0xD028+i,0);
 for(unsigned slot=0;slot<10;slot++){
  wr(c,0xD028+slot*6,255);wr(c,0xD029+slot*6,255);
 }
 wr(c,0xD028,0xA1);wr(c,0xD029,0x98);wr(c,0xD02A,1);
 wr(c,0xD02B,9);wr(c,0xD02C,0x24);wr(c,0xD02D,0x42);
 wr(c,0xD021,0x80);wr(c,0xD309,0);
 for(unsigned plane=0;plane<2;plane++){
  wr(c,0xFF4F,plane);for(unsigned i=0;i<288;i++)wr(c,0x98A0+i,0xA5);
 }
 wr(c,0xFF4F,1);call(c,0x5A0E);
 unsigned columnOK=(rd(c,0xFF4F)&1)==1&&rd(c,0xD021)==0;
 for(unsigned plane=0;plane<2;plane++){
  wr(c,0xFF4F,plane);
  for(unsigned i=0;i<288;i++)columnOK&=rd(c,0x98A0+i)==
   (plane==1&&i%32==1?rd(c,0x4224+i/32):0xA5);
 }
 require(columnOK,"original nine-byte column, current plane only",0);
 /* Independent D309 tail: 6 columns x 10 rows, current plane and toggle. */
 for(unsigned firstPlane=0;firstPlane<2;firstPlane++){
  wr(c,0xD021,0);wr(c,0xD309,1);
  for(unsigned i=0;i<120;i++)wr(c,0xD34A+i,(i*37+11)&255);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);for(unsigned i=0;i<320;i++)wr(c,0x9880+i,0xA5);
  }
  wr(c,0xFF4F,firstPlane);call(c,0x5A0E);
  unsigned ok=rd(c,0xD309)==0&&(rd(c,0xFF4F)&1)==0&&
              cpu->hl==0xD34A+(firstPlane?60:120);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned i=0;i<320;i++){
    unsigned row=i/32,col=i%32,value=0xA5;
    if(col>=13&&col<19&&(firstPlane==0||plane==1)){
     unsigned sourceIndex=(firstPlane?0:plane*60)+row*6+col-13;
     value=(sourceIndex*37+11)&255;
    }
    ok&=rd(c,0x9880+i)==value;
   }
  }
  require(ok,"D309 tail rectangle, current plane and source advancement",firstPlane);
 }
 /* Palette upload through its original thunk, LCD off. */
 for(unsigned pending=0;pending<2;pending++){
  for(unsigned i=0;i<128;i++){
   unsigned value=(i*37+11)&(i%2?127:255);wr(c,0xC222+i,value);
  }
  for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){
   wr(c,palette?0xFF6A:0xFF68,i);wr(c,palette?0xFF6B:0xFF69,0x19);
  }
  wr(c,0xC221,pending);cpu->af=0x5AB0;cpu->bc=0x1234;cpu->de=0x5678;cpu->hl=0x9ABC;
  call(c,0x018C);
  unsigned ok=rd(c,0xC221)==0&&cpu->af==0x5AB0&&cpu->bc==0x1234&&
              cpu->de==0x5678&&cpu->hl==0x9ABC;
  for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){
   wr(c,palette?0xFF6A:0xFF68,i);
   unsigned sourceIndex=palette*64+i;
   unsigned value=pending?((sourceIndex*37+11)&(sourceIndex%2?127:255)):0x19;
   ok&=rd(c,palette?0xFF6B:0xFF69)==value;
  }
  require(ok,"pending palette flag, register preservation and both palettes",pending);
 }
 /* Install and execute the original ten-byte DMA template in disposable HRAM. */
 for(unsigned i=0;i<10;i++)wr(c,0xFF80+i,0xA5);
 wr(c,0xFF8A,0x37);call(c,0x09EB);
 unsigned installed=rd(c,0xFF8A)==0x37;
 for(unsigned i=0;i<10;i++)installed&=rd(c,0xFF80+i)==rd(c,0x09F9+i);
 require(installed,"exact HRAM DMA template and adjacent byte preserved",0);
 for(unsigned i=0;i<160;i++)wr(c,0xC000+i,(i*37+11)&255);
 call(c,0xFF80);
 unsigned dmaOK=1;for(unsigned i=0;i<160;i++)dmaOK&=rd(c,0xFE00+i)==((i*37+11)&255);
 require(dmaOK,"HRAM DMA copies all 160 OAM bytes",0);
 /* Full original consumer entry, including DMA and inactive-palette callback. */
 for(unsigned i=0;i<60;i++)wr(c,0xD028+i,0);
 for(unsigned slot=0;slot<10;slot++){
  wr(c,0xD028+slot*6,255);wr(c,0xD029+slot*6,255);
 }
 wr(c,0xD028,0x40);wr(c,0xD029,0x98);wr(c,0xD02A,1);
 wr(c,0xD02B,1);wr(c,0xD02C,0);wr(c,0xD02D,0xD8);wr(c,0xD800,0x67);
 wr(c,0xD021,0x80);wr(c,0xD309,0);wr(c,0xC221,0);
 for(unsigned plane=0;plane<2;plane++){
  wr(c,0xFF4F,plane);wr(c,0x9840,0xA5);wr(c,0x9841,0xA5);
 }
 for(unsigned i=0;i<160;i++)wr(c,0xC000+i,(i*19+7)&255);
 wr(c,0xFF4F,0);call(c,0x5A08);
 unsigned integrated=rd(c,0xD021)==0&&rd(c,0xC221)==0&&rd(c,0xD309)==0&&
                     rd(c,0xD028)==255&&rd(c,0xD029)==255;
 for(unsigned i=0;i<160;i++)integrated&=rd(c,0xFE00+i)==((i*19+7)&255);
 for(unsigned plane=0;plane<2;plane++){
  wr(c,0xFF4F,plane);
  integrated&=rd(c,0x9840)==(plane?0xA5:0x67)&&rd(c,0x9841)==0xA5;
 }
 require(integrated,"full pending consumer with installed DMA and palette callback",0);
 /* Actual state-0 source ranges, isolated banked-copy calls, LCD off. */
 const unsigned graphicsSource[]={0x5C0A,0x6002,0x5CE2,0x71B4};
 const unsigned graphicsSize[]={16,0x1800,160,32};
 const unsigned graphicsDestination[]={0x9000,0x8000,0x8100,0x8000};
 for(unsigned range=0;range<4;range++){
  unsigned source=graphicsSource[range],size=graphicsSize[range],destination=graphicsDestination[range];
  unsigned window=source>=0x6000,select=window?0x15:0x14;
  unsigned expectedGraphics[0x1800];
  wr(c,window?0x37FF:0x27FF,select);wr(c,window?0x3800:0x2800,0);
  for(unsigned i=0;i<size;i++)expectedGraphics[i]=rd(c,source+i);
  wr(c,0x27FF,4);wr(c,0x2800,0);wr(c,0x37FF,5);wr(c,0x3800,0);
  wr(c,0xFFAB,4);wr(c,0xFFAC,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);
  wr(c,0xC113,4);wr(c,0xC114,0);wr(c,0xC115,5);wr(c,0xC116,0);
  wr(c,0xC21C,select);wr(c,0xC21D,0);wr(c,0xFF4F,range==0?1:0);
  for(unsigned i=0;i<size+1;i++)wr(c,destination+i,0xA5);
  cpu->hl=source;cpu->de=destination;cpu->bc=size;call(c,0x019E);
  unsigned ok=cpu->hl==source+size&&cpu->de==destination+size&&cpu->bc==0&&
              rd(c,0xFFAB)==4&&rd(c,0xFFAD)==5&&rd(c,0xFFAC)==0&&rd(c,0xFFAE)==0&&
              rd(c,0xC113)==4&&rd(c,0xC115)==5&&rd(c,destination+size)==0xA5&&
              (rd(c,0xFF4F)&1)==(range==0?1:0);
  for(unsigned i=0;i<size;i++)ok&=rd(c,destination+i)==expectedGraphics[i];
  require(ok,"actual graphics interval, mapper restoration and trailing sentinel",range);
 }
 /* OAM buffer clear: WRAM only, exactly 160 bytes. */
 wr(c,0x27FF,0x14);wr(c,0x2800,0);wr(c,0xFF70,1);
 for(unsigned i=0;i<160;i++)wr(c,0xC000+i,0xA5);
 wr(c,0xC0A0,0x37);cpu->bc=0x1234;cpu->de=0xBEEF;call(c,0x5B26);
 unsigned oamClear=cpu->hl==0xC0A0&&cpu->bc==0x0034&&cpu->de==0xBEEF&&rd(c,0xC0A0)==0x37;
 for(unsigned i=0;i<160;i++)oamClear&=rd(c,0xC000+i)==0;
 require(oamClear,"OAM WRAM buffer extent, registers and sentinel",0);
 /* Synthetic flash headers: mutate disposable backing memory, no command/save. */
 struct GB *fixtureGB=c->board;
 require(fixtureGB->memory.sram&&fixtureGB->sramSize>=GB_SIZE_MBC6_FLASH_STORAGE,
         "disposable flash backing available",0);
 uint8_t *fixtureFlash=fixtureGB->memory.sram+fixtureGB->sramSize-GB_SIZE_MBC6_FLASH_STORAGE;
 unsigned originalCount=fixtureFlash[5],originalMarker=fixtureFlash[0x44];
 for(unsigned mode=0;mode<6;mode++){
  fixtureFlash[5]=mode==2||mode==5?16:mode==3?17:3;
  fixtureFlash[0x44]=mode==4?0:255;
  for(unsigned i=0;i<40;i++)wr(c,0xD1E6+i,0);
  unsigned entries=mode==0?0:mode==5?17:1;
  unsigned prefix=mode==1?1:0;
  if(prefix){wr(c,0xD1E6,15);wr(c,0xD1E7,2);}
  for(unsigned i=0;i<entries;i++){
   wr(c,0xD1E6+2*(prefix+i),16);wr(c,0xD1E7+2*(prefix+i),3);
  }
  wr(c,0xD1E6+2*(prefix+entries),255);
  wr(c,0xD06B,2);wr(c,0xCEE9,0);
  wr(c,0x37FF,7);wr(c,0x3800,0);wr(c,0xFFAD,7);wr(c,0xFFAE,0);
  wr(c,0xC115,7);wr(c,0xC116,0);call(c,0x5B31);
  unsigned sum=mode==0||mode==3||mode==4?0:mode==1?3:16;
  unsigned ok=rd(c,0xD005)==sum&&rd(c,0xC5C9)==sum&&
              rd(c,0xC5CB)==0x20&&rd(c,0xC5C4)==0&&
              !fixtureGB->memory.mbcState.mbc6.flashEnable&&
              !fixtureGB->memory.mbcState.mbc6.flashWriteEnable&&
              !fixtureGB->memory.mbcState.mbc6.flashOperationActive;
  ok&=rd(c,0xFFAD)==(mode==0?7:0)&&rd(c,0xFFAE)==(mode==0?0:8)&&
      rd(c,0xC115)==(mode==0?7:0)&&rd(c,0xC116)==(mode==0?0:8);
  require(ok,"header count filters, wrap and selected B window remains",mode);
 }
 fixtureFlash[5]=originalCount;fixtureFlash[0x44]=originalMarker;
 /* Callback pointer/stub setters: forced calls, no interrupt dispatch. */
 const unsigned callbackTargets[]={0,1,0x5A08,0xBEEF,0xFFFF};
 for(unsigned slot=0;slot<2;slot++)for(unsigned n=0;n<5;n++){
  unsigned target=callbackTargets[n],pointer=slot?0xFF92:0xFF8E;
  cpu->af=0x5AB0;cpu->bc=0x1234;cpu->de=target;
  call(c,slot?0x0156:0x0150);
  require(rd(c,pointer)==(target&255)&&rd(c,pointer+1)==(target>>8)&&
          cpu->af==0x5AB0&&cpu->bc==0x1234&&cpu->de==target&&cpu->hl==pointer+1,
          "runtime callback pointer and register preservation",slot*10+n);
  unsigned stub=slot?0xC682:0xC67F;
  wr(c,stub,0xA5);wr(c,stub+1,0x11);wr(c,stub+2,0x22);
  cpu->af=0x5AB0;cpu->bc=0x1234;cpu->de=target;
  call(c,slot?0x0159:0x0153);
  require(rd(c,stub)==(target?0xC3:0xD9)&&
          rd(c,stub+1)==(target?(target&255):0x11)&&
          rd(c,stub+2)==(target?(target>>8):0x22)&&
          cpu->af==0x5AB0&&cpu->bc==0x1234&&cpu->de==target&&
          cpu->hl==stub+(target?2:0),
          "interrupt stub JP or RETI, preserved AF and untouched null operand",slot*10+n);
 }
 /* Per-entry palette helpers: indices 0..7, LCD off. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x14);wr(c,0x2800,0);wr(c,0xFF70,1);
 for(unsigned kind=0;kind<2;kind++)for(unsigned index=0;index<8;index++){
  for(unsigned i=0;i<8;i++)wr(c,0xD800+i,(i*37+11)&(i%2?127:255));
  for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){
   wr(c,palette?0xFF6A:0xFF68,i);wr(c,palette?0xFF6B:0xFF69,0x19);
  }
  cpu->a=index;cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;
  call(c,kind?0x0174:0x0171);
  unsigned ok=cpu->a==index+1&&cpu->hl==0xD808&&cpu->bc==0x1280&&cpu->de==0xBEEF;
  for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){
   wr(c,palette?0xFF6A:0xFF68,i);
   unsigned value=palette==kind&&i>=index*8&&i<index*8+8?
    (((i-index*8)*37+11)&(i%2?127:255)):0x19;
   ok&=rd(c,palette?0xFF6B:0xFF69)==value;
  }
  require(ok,"individual palette slot, next index and unchanged others",kind*10+index);
 }
 cpu->bc=0x1234;cpu->de=0xBEEF;call(c,0x481B);
 unsigned whiteOK=cpu->a==8&&cpu->hl==0x4886&&cpu->bc==0x1280&&cpu->de==0xBEEF;
 for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){
  wr(c,palette?0xFF6A:0xFF68,i);whiteOK&=rd(c,palette?0xFF6B:0xFF69)==(i%2?127:255);
 }
 require(whiteOK,"menu initialization sets all palette entries",0);
 /* Loader with new and existing correctly sized SYS1 records. */
 for(unsigned mode=0;mode<2;mode++){
  wr(c,0x0000,0x0A);wr(c,0x0400,0);wr(c,0x0800,1);
  wr(c,0xFFAF,0);wr(c,0xFFB0,1);
  for(unsigned i=0;i<4096;i++)wr(c,0xA000+i,0);
  if(mode){
   cpu->bc=0x02A3;cpu->de=0x3ED8;call(c,0x01B6);
   for(unsigned i=0;i<0x02A3;i++)wr(c,0xA317+i,(i*37+11)&255);
   call(c,0x01B9);
  }
  for(unsigned i=0;i<0x02A3;i++)wr(c,0xD064+i,0xA5);
  wr(c,0xD307,0x37);call(c,0x45FF);
  unsigned ok=rd(c,0xD307)==0x37&&rd(c,0xC677)==0x17&&rd(c,0xC678)==0xA3;
  for(unsigned i=0;i<0x02A3;i++)ok&=rd(c,0xD064+i)==(mode?((i*37+11)&255):0);
  require(ok,"new/existing SYS1 loader exact payload and destination sentinel",mode);
 }
 /* Full menu-runtime initialization with an existing correctly sized record. */
 for(unsigned i=0;i<0x02A3;i++)wr(c,0xD064+i,0xA5);
 wr(c,0xC671,3);wr(c,0xC5A3,0x37);wr(c,0xD000,0x37);
 wr(c,0xD021,0x37);wr(c,0xD309,0x37);call(c,0x5BC6);
 unsigned initOK=rd(c,0xD004)==3&&rd(c,0xC5A3)==1&&rd(c,0xD000)==0&&
                 rd(c,0xD021)==0&&rd(c,0xD309)==0&&
                 rd(c,0xFF8E)==8&&rd(c,0xFF8F)==0x5A;
 for(unsigned i=0;i<0x02A3;i++)initOK&=rd(c,0xD064+i)==((i*37+11)&255);
 for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){
  wr(c,palette?0xFF6A:0xFF68,i);initOK&=rd(c,palette?0xFF6B:0xFF69)==(i%2?127:255);
 }
 require(initOK,"full runtime init storage, palettes, flags and registered consumer",0);
 /* OAM list indicators, including deliberately wrapped offset values. */
 const unsigned listOffsets[]={0,1,251,252,255},listCounts[]={0,5,6,255};
 for(unsigned blink=0;blink<2;blink++)for(unsigned oi=0;oi<5;oi++)
 for(unsigned ci=0;ci<4;ci++){
  unsigned offset=listOffsets[oi],count=listCounts[ci];
  wr(c,0xD006,blink?0x10:0);wr(c,0xD002,offset);wr(c,0xD003,count);
  for(unsigned i=0;i<10;i++)wr(c,0xC06F+i,0xA5);
  call(c,0x461A);
  unsigned upper=!blink&&offset!=0,lower=!blink&&((offset+5)&255)<count;
  const unsigned top[]={0x30,0xA0,0,0},bottom[]={0x78,0xA0,1,0};
  unsigned ok=rd(c,0xC06F)==0xA5&&rd(c,0xC078)==0xA5;
  for(unsigned i=0;i<4;i++){
   ok&=rd(c,0xC070+i)==(upper?top[i]:i?0xA5:0);
   ok&=rd(c,0xC074+i)==(lower?bottom[i]:i?0xA5:0);
  }
  require(ok,"list OAM indicators, blink bit, wrapped comparison and sentinels",
          blink*100+oi*10+ci);
 }
 /* Held indicator producer: whole-byte equality and bit-10 priority. */
 const unsigned heldValues[]={0,1,0x10,0x20,0x30,0xFF};
 for(unsigned oi=0;oi<6;oi++)for(unsigned ni=0;ni<6;ni++){
  unsigned old=heldValues[oi],now=heldValues[ni],changed=old!=now;
  wr(c,0xD015,old);wr(c,0xFF96,now);wr(c,0xD021,0x37);
  for(unsigned i=0;i<14;i++)wr(c,0xD045+i,0xA5);
  call(c,0x478D);
  unsigned ok=rd(c,0xD015)==now&&rd(c,0xD021)==(changed?1:0x37)&&
              rd(c,0xD045)==0xA5&&rd(c,0xD052)==0xA5;
  for(unsigned which=0;which<2;which++){
   unsigned held=which?now:old,base=which?0xD04C:0xD046;
   unsigned active=changed&&(held&0x30),bit10=held&0x10;
   const unsigned descriptor[]={bit10?0x6F:0x64,0x98,1,1,
    which?(bit10?0x17:0x19):(bit10?0x13:0x15),0x48};
   for(unsigned i=0;i<6;i++)ok&=rd(c,base+i)==(active?descriptor[i]:0xA5);
  }
  require(ok,"held producer equality, priority, descriptors and sentinels",oi*10+ni);
 }
 /* Producer -> consumer body; callbacks remain skipped in these chain cases. */
 const unsigned chainOld[]={0,0x10,0x10,0x20},chainNew[]={0x10,0,0x20,0x10};
 for(unsigned mode=0;mode<4;mode++){
  for(unsigned i=0;i<60;i++)wr(c,0xD028+i,0);
  for(unsigned slot=0;slot<10;slot++){
   wr(c,0xD028+slot*6,255);wr(c,0xD029+slot*6,255);
  }
  wr(c,0xD015,chainOld[mode]);wr(c,0xFF96,chainNew[mode]);wr(c,0xD021,0);
  wr(c,0xD309,0);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);for(unsigned i=0;i<32;i++)wr(c,0x9860+i,0xA5);
  }
  wr(c,0xFF4F,0);call(c,0x478D);call(c,0x5A0E);
  unsigned ok=rd(c,0xD021)==0&&rd(c,0xD015)==chainNew[mode]&&(rd(c,0xFF4F)&1)==0;
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned i=0;i<32;i++){
    unsigned expected=0xA5;
    if(chainOld[mode]&&i==(chainOld[mode]==0x10?15:4))
     expected=rd(c,(chainOld[mode]==0x10?0x4813:0x4815)+plane);
    if(chainNew[mode]&&i==(chainNew[mode]==0x10?15:4))
     expected=rd(c,(chainNew[mode]==0x10?0x4817:0x4819)+plane);
    ok&=rd(c,0x9860+i)==expected;
   }
  }
  require(ok,"held producer to queue-consumer planes and padding",mode);
 }
 /* Text-step timer paths and empty strings, without calling the text sink. */
 const unsigned textTimers[]={0,2,3,255};
 for(unsigned mode=0;mode<4;mode++){
  wr(c,0x27FF,0x14);wr(c,0x2800,0);
  wr(c,0xD016,textTimers[mode]);wr(c,0xC1BA,2);wr(c,0xC1C2,0xA5);
  wr(c,0xD017,0);wr(c,0xD018,0xD8);wr(c,0xD019,0x37);wr(c,0xD01A,7);
  for(unsigned i=0;i<4;i++)wr(c,0xD329+i,0xA5);
  call(c,0x4656);
  require(rd(c,0xD016)==(textTimers[mode]?textTimers[mode]-1:0)&&
          rd(c,0xC1C2)==0xA5&&rd(c,0xD017)==0&&rd(c,0xD018)==0xD8&&
          rd(c,0xD019)==0x37&&rd(c,0xD01A)==7&&rd(c,0xD329)==0xA5&&
          rd(c,0xD32A)==0xA5&&rd(c,0xD32B)==0xA5&&rd(c,0xD32C)==0xA5,
          "text timer skips source/output",mode);
 }
 const unsigned emptyTextModes[]={1,2,255};
 for(unsigned mode=0;mode<3;mode++){
  wr(c,0xD016,1);wr(c,0xC1BA,emptyTextModes[mode]);wr(c,0xC1C2,0xA5);
  wr(c,0xD017,0);wr(c,0xD018,0xD8);wr(c,0xD019,0x37);wr(c,0xD01A,7);
  wr(c,0xD800,0);cpu->de=0xBEEF;
  call(c,0x4656);
  require(rd(c,0xD016)==0&&rd(c,0xC1C2)==0x37&&cpu->de==0xD801&&
          rd(c,0xD017)==0&&rd(c,0xD018)==0xD8&&rd(c,0xD019)==0x37&&
          rd(c,0xD01A)==7&&rd(c,0xD329)==0xA5&&rd(c,0xD32A)==0xA5&&
          rd(c,0xD32B)==0xA5&&rd(c,0xD32C)==0xA5,
          "empty text returns without sink or pointer store",mode);
 }
 /* Original cursor arithmetic and bounded OAM-buffer writes, LCD off. */
 for(unsigned frame=0;frame<256;frame++){
  wr(c,0xFF8B,frame);cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;
  call(c,0x2DC3);
  unsigned jitter=((((frame>>2)&3)^3)-2)&255;
  require(cpu->a==jitter&&cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800,
          "cursor frame byte arithmetic",frame);
 }
 const unsigned cursorRows[]={0,1,15,16,255};
 for(unsigned row=0;row<5;row++)for(unsigned frame=0;frame<4;frame++){
  unsigned value=cursorRows[row];wr(c,0xFF8B,frame*4);wr(c,0xD007,value);
  wr(c,0x27FF,0x14);wr(c,0x2800,0);
  for(unsigned i=0;i<5;i++)wr(c,0xC000+i,0xA5);
  call(c,0x488E);
  require(rd(c,0xC000)==((((value<<4)|(value>>4))+0x38)&255)&&
          rd(c,0xC001)==((((frame^3)-2)+8)&255)&&rd(c,0xC002)==0x76&&
          rd(c,0xC003)==8&&rd(c,0xC004)==0xA5,"list cursor entry and guard",row*4+frame);
 }
 const unsigned removeOffsets[]={0x10,0x38,0x68};
 for(unsigned index=0;index<4;index++)for(unsigned frame=0;frame<4;frame++){
  wr(c,0xFF8B,frame*4);wr(c,0xD01C,index==3?255:index);
  for(unsigned i=0;i<5;i++)wr(c,0xC000+i,0xA5);
  call(c,0x48AB);
  unsigned x=index==3?0:((((frame^3)-2)+removeOffsets[index])&255);
  require(rd(c,0xC000)==0x90&&rd(c,0xC001)==x&&
          rd(c,0xC002)==(index==3?0xA5:0x76)&&rd(c,0xC003)==(index==3?0xA5:8)&&
          rd(c,0xC004)==0xA5,"remove cursor entry and skipped fields",index*4+frame);
 }
 /* State equality/mismatch controls which row is selected or hidden. */
 for(unsigned mode=0;mode<5;mode++)for(unsigned frame=0;frame<4;frame++){
  wr(c,0xFF8B,frame*4);wr(c,0xD006,mode==0?2:0);
  wr(c,0xD001,1);wr(c,0xD00A,mode==1?2:1);
  wr(c,0xD002,3);wr(c,0xD00B,mode==2?4:3);
  wr(c,0xD007,1);wr(c,0xD00C,mode==3?2:1);
  for(unsigned i=0;i<5;i++)wr(c,0xC000+i,0xA5);
  call(c,0x48DA);
  unsigned active=(mode==0||mode==3),row=mode==3?2:1;
  require(rd(c,0xC000)==(active?0x38+16*row:0)&&
          rd(c,0xC001)==(active?((((frame^3)-2)+8)&255):0xA5)&&
          rd(c,0xC002)==(active?0x76:0xA5)&&rd(c,0xC003)==(active?8:0xA5)&&
          rd(c,0xC004)==0xA5,"move cursor equality and bit branch",mode*4+frame);
 }
 /* Unhandled input returns without executing external callees. */
 const unsigned ignoredHeld[]={0,1,4,5},ignoredPressed[]={0,4,0x80,0x84};
 for(unsigned held=0;held<4;held++)for(unsigned pressed=0;pressed<4;pressed++){
  wr(c,0x27FF,0x14);wr(c,0x2800,0);
  wr(c,0xFF98,ignoredHeld[held]);wr(c,0xFF97,ignoredPressed[pressed]);
  for(unsigned i=0;i<32;i++)wr(c,0xD000+i,0xA5);
  wr(c,0xD004,0);wr(c,0xC671,0xA5);call(c,0x4940);
  unsigned ok=rd(c,0xC671)==0xA5;
  for(unsigned i=0;i<32;i++)ok&=rd(c,0xD000+i)==(i==4?0:0xA5);
  require(ok,"unhandled input preserves menu fields",held*4+pressed);
 }
 /* Pair lookup: nth matching category, exhaustion and B=$FF wrap. */
 const unsigned lookupIndices[]={0,1,2,255};
 for(unsigned mode=0;mode<4;mode++){
  unsigned length=mode==3?256:4;
  for(unsigned i=0;i<length;i++){
   wr(c,0xD1E6+i*2,0x30+(i%16));
   wr(c,0xD1E7+i*2,mode==3?1:((i==1||i==3)?1:0));
  }
  wr(c,0xD1E6+length*2,0xFF);cpu->b=lookupIndices[mode];cpu->c=1;
  call(c,0x4CDA);
  unsigned index=mode==0?1:mode==1?3:255;
  require(cpu->hl==(mode==2?0xD1EF:0xD1E6+2*index)&&
          rd(c,0xC5C3)==(mode==2?0xFF:0x30+index%16)&&
          cpu->a==(mode==2?0xFF:1)&&cpu->b==(mode==2?1:0),
          "pair lookup match exhaustion and index wrap",mode);
 }
 printf("PASS SYNTHETIC storage probes: %u assertions; version=%s commit=%s\n",
        checks,projectVersion,gitCommit);
 c->unloadROM(c);mCoreConfigDeinit(&c->config);c->deinit(c);return 0;
}
