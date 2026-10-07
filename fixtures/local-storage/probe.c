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
 /* Action-input unhandled bits avoid external sound/text callees. */
 for(unsigned held=0;held<4;held++)for(unsigned pressed=0;pressed<4;pressed++){
  wr(c,0xFF98,ignoredHeld[held]);wr(c,0xFF97,ignoredPressed[pressed]);
  for(unsigned i=0;i<32;i++)wr(c,0xD000+i,0xA5);
  call(c,0x4C6F);unsigned ok=1;
  for(unsigned i=0;i<32;i++)ok&=rd(c,0xD000+i)==0xA5;
  require(ok,"unhandled action input preserves menu fields",held*4+pressed);
 }
 /* Correct-size synthetic SYS1; all payload bytes outside the copied span checked. */
 const unsigned nameRows[]={0,1,6,16,255},nameLengths[]={0,3,16};
 for(unsigned row=0;row<5;row++)for(unsigned mode=0;mode<3;mode++){
  wr(c,0x0000,0x0A);wr(c,0x0400,0);wr(c,0x0800,1);
  wr(c,0xFFAF,0);wr(c,0xFFB0,1);
  for(unsigned i=0;i<4096;i++)wr(c,0xA000+i,0);
  cpu->bc=0x02A3;cpu->de=0x3ED8;call(c,0x01B6);
  for(unsigned i=0;i<675;i++)wr(c,0xA317+i,0xA5);
  call(c,0x01B9);
  for(unsigned i=0;i<17;i++)wr(c,0xD800+i,i==nameLengths[mode]?0:i+1);
  wr(c,0xD001,nameRows[row]);cpu->de=0xD800;call(c,0x4C3E);
  unsigned closed=rd(c,0xA317)==0xFF;
  /* Close disables SRAM; explicitly map it again only to inspect the fixture. */
  wr(c,0x0000,0x0A);wr(c,0x0400,0);wr(c,0x0800,1);
  unsigned value=nameRows[row],offset=0x112+(((value<<4)|(value>>4))&255);
  unsigned copied=nameLengths[mode]==16?16:nameLengths[mode]+1,ok=closed;
  for(unsigned i=0;i<675;i++){
   unsigned expected=0xA5;
   if(i>=offset&&i<offset+copied)expected=i-offset==nameLengths[mode]?0:i-offset+1;
   ok&=rd(c,0xA317+i)==expected;
  }
  require(ok,"box-name copy termination wrap and other record bytes",row*3+mode);
 }
 /* RST $00 dispatcher consumes its return-address table pointer. */
 for(unsigned slot=0;slot<128;slot++){
  unsigned target=0xC200+slot*4;
  wr(c,0xD800+slot*2,target&255);wr(c,0xD801+slot*2,target>>8);
 }
 for(unsigned index=0;index<256;index++){
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
  wr(c,0xCFFE,0);wr(c,0xCFFF,0xD8);cpu->a=index;cpu->bc=0x1234;cpu->pc=0x05F5;
  unsigned target=0xC200+(index&127)*4,steps=0;
  while(cpu->pc!=target&&steps++<1000)c->step(c);
  require(cpu->pc==target&&cpu->sp==0xD000&&cpu->hl==target&&cpu->de==target&&
          cpu->a==((index*2)&255)&&cpu->bc==0x1234,
          "RST table index byte wrap and consumed return pointer",index);
 }
 /* Forced interrupt dispatch with null and WRAM callback targets. */
 const unsigned interruptEntries[]={0x061B,0x0630,0x0645};
 const unsigned interruptSlots[]={0xFF92,0xFF8C,0xFF90};
 for(unsigned entry=0;entry<3;entry++)for(unsigned active=0;active<2;active++){
  unsigned slot=interruptSlots[entry];wr(c,slot,0);wr(c,slot+1,active?0xC2:0);
  wr(c,0xC200,0x21);wr(c,0xC201,0x10);wr(c,0xC202,0xC2);
  wr(c,0xC203,0x34);wr(c,0xC204,0xC9);wr(c,0xC210,0xA5);wr(c,0xFF8A,0x37);
  cpu->af=0x5AB0;cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;
  call(c,interruptEntries[entry]);
  require(cpu->af==0x5AB0&&cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800&&
          rd(c,0xC210)==(active?0xA6:0xA5)&&rd(c,0xFF8A)==0x37,
          "interrupt null/callback register restoration",entry*2+active);
 }
 cpu->af=0x5AB0;cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;call(c,0x065A);
 require(cpu->af==0x5AB0&&cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800,
         "return-only interrupt restores registers",0);
 /* Stop VBlank before $069E maintenance: no natural interrupt claim. */
 for(unsigned active=0;active<2;active++){
  wr(c,0xFF8E,0);wr(c,0xFF8F,active?0xC2:0);wr(c,0xFF8A,0x37);wr(c,0xC210,0xA5);
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
  wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);
  cpu->af=0x5AB0;cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;cpu->pc=0x0601;
  unsigned steps=0;while(cpu->pc!=0x069E&&steps++<1000)c->step(c);
  require(cpu->pc==0x069E&&cpu->sp==0xCFF6&&rd(c,0xFF8A)==1&&
          rd(c,0xC210)==(active?0xA6:0xA5)&&
          rd(c,0xCFF6)==0&&rd(c,0xCFF7)==0xD8&&rd(c,0xCFF8)==0xEF&&rd(c,0xCFF9)==0xBE&&
          rd(c,0xCFFA)==0x34&&rd(c,0xCFFB)==0x12&&rd(c,0xCFFC)==0xB0&&rd(c,0xCFFD)==0x5A,
          "VBlank dispatch before maintenance",active);
 }
 /* Forced cartridge startup, stopped before the bank-A $16 init call. */
 const unsigned startupA[]={0x11,0,0x80,255};
 for(unsigned mode=0;mode<4;mode++){
  wr(c,0xFF40,0);wr(c,0xFFFF,0);wr(c,0xFF0F,0);
  for(unsigned i=0;i<4096;i++)wr(c,0xC000+i,0xA5);
  for(unsigned bank=1;bank<8;bank++){
   wr(c,0xFF70,bank);for(unsigned i=0;i<4096;i++)wr(c,0xD000+i,0xA5);
  }
  for(unsigned i=0;i<127;i++)wr(c,0xFF80+i,0xA5);
  struct GB *g=c->board;g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->a=startupA[mode];cpu->pc=0x02B8;
  unsigned steps=0;while(cpu->pc!=0x0373&&steps++<400000)c->step(c);
  require(cpu->pc==0x0373&&cpu->sp==0xFFFE&&rd(c,0xFF9C)==(startupA[mode]==0x11)&&
          rd(c,0xFFAB)==0x16&&rd(c,0xFFAC)==0&&rd(c,0xFFFF)==0,
          "startup prefix registers model byte and A selector",mode);
  unsigned ok=1;
  for(unsigned i=0;i<4096;i++){
   unsigned expected=(i==0x67F||i==0x682)?0xD9:0;
   ok&=rd(c,0xC000+i)==expected;
  }
  for(unsigned bank=1;bank<8;bank++){
   wr(c,0xFF70,bank);for(unsigned i=0;i<4096;i++)ok&=rd(c,0xD000+i)==0;
  }
  for(unsigned i=0;i<127;i++){
   unsigned address=0xFF80+i,expected=address==0xFF9C?(startupA[mode]==0x11):address==0xFFAB?0x16:0;
   ok&=rd(c,address)==expected;
  }
  require(ok,"startup clears WRAM banks and HRAM with explicit fields",mode);
 }
 /* Forced DMG fallback prefix; stop before sound helper $0252. LCD off. */
 for(unsigned mode=0;mode<4;mode++){
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);wr(c,0xFF40,0);
  wr(c,0x27FF,0x16);wr(c,0x2800,0);
  wr(c,0x37FF,mode);wr(c,0x3800,0);wr(c,0xFFAD,mode);wr(c,0xFFAE,0xA5);
  wr(c,0xFF42,0xA5);wr(c,0xFF43,0xA5);wr(c,0xFF4A,0xA5);wr(c,0xFF4B,0xA5);
  struct GB *g=c->board;g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->sp=0xCFFE;cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;cpu->pc=0x416C;
  unsigned steps=0;while(cpu->pc!=0x419D&&steps++<200)c->step(c);
  require(cpu->pc==0x419D&&cpu->sp==0xCFFE&&cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800&&
          rd(c,0xFFAD)==0x1F&&rd(c,0xFFAE)==0&&rd(c,0x6000)==0xFF&&rd(c,0x6002)==0x7F,
          "DMG prefix selects B1F ROM and preserves register pairs",mode);
  require(rd(c,0xFF47)==0xE4&&rd(c,0xFF48)==0xE4&&rd(c,0xFF49)==0xE4&&
          rd(c,0xFF42)==0&&rd(c,0xFF43)==0&&rd(c,0xFF4A)==0&&rd(c,0xFF4B)==7&&
          rd(c,0xFF24)==0x77&&rd(c,0xFF25)==0xFF,
          "DMG prefix palette scroll window and sound routes",mode);
 }
 /* Main dispatch: all byte indices, stop immediately before JP HL. */
 for(unsigned index=0;index<256;index++){
  wr(c,0xC623,index);wr(c,0xFFFF,0);wr(c,0xFF0F,0);
  struct GB *g=c->board;g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  unsigned table=0x03A8+((index*2)&255),target=rd(c,table)|(rd(c,table+1)<<8);
  cpu->sp=0xCFFE;cpu->bc=0x1234;cpu->pc=0x0391;
  unsigned steps=0;while(cpu->pc!=0x03A5&&steps++<100)c->step(c);
  require(cpu->pc==0x03A5&&cpu->hl==target&&cpu->de==target&&cpu->bc==0x1234&&
          cpu->sp==0xCFFC&&rd(c,0xCFFC)==0xA6&&rd(c,0xCFFD)==3&&rd(c,0xC623)==index,
          "main dispatch byte wrap target and pushed return",index);
 }
 const unsigned stateValues[]={3,4,5,1,2,7,6};
 for(unsigned index=0;index<7;index++){
  wr(c,0xC623,0xA5);cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;
  call(c,0x047C+6*index);
  require(rd(c,0xC623)==stateValues[index]&&cpu->a==stateValues[index]&&
          cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800,
          "main result handler state and preserved register pairs",index);
 }
 /* State-6 tail only: external callback $0264 has not been executed. */
 for(unsigned value=0;value<256;value++){
  wr(c,0xC623,value);cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;call(c,0x058A);
  require(rd(c,0xC623)==(value==7?7:2)&&cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800,
          "state6 forced post-callback tail",value);
 }
 const unsigned tailEntries[]={0x0564,0x0571,0x059E,0x05AB};
 const unsigned tailStates[]={2,2,8,2};
 for(unsigned index=0;index<4;index++){
  wr(c,0xC623,0xA5);cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;call(c,tailEntries[index]);
  require(rd(c,0xC623)==tailStates[index]&&cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800,
          "remaining state tails preserve register pairs",index);
 }
 const unsigned stateEntries[]={0x056A,0x0577,0x057F,0x0597,0x05A4};
 const unsigned callSites[]={0x056E,0x057B,0x0587,0x059B,0x05A8};
 const unsigned callbackArgs[]={4,10,3,2,13};
 for(unsigned index=0;index<5;index++){
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);wr(c,0xC623,0xA5);
  struct GB *g=c->board;g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->sp=0xCFFE;cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;cpu->pc=stateEntries[index];
  unsigned steps=0;while(cpu->pc!=callSites[index]&&steps++<50)c->step(c);
  require(cpu->pc==callSites[index]&&cpu->sp==0xCFFE&&cpu->a==callbackArgs[index]&&
          cpu->bc==0x0034&&cpu->de==0xBEEF&&cpu->hl==0xD800&&rd(c,0xC623)==(index==2?0:0xA5),
          "remaining state prefix before external callback",index);
 }
 /* State9 mapping prefix and separate restart tail, external $44AA omitted. */
 wr(c,0xFFFF,0);wr(c,0xFF0F,0);wr(c,0x27FF,0);wr(c,0x2800,0);
 struct GB *restartGB=c->board;restartGB->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
 cpu->sp=0xCFFE;cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;cpu->pc=0x05B1;
 unsigned restartSteps=0;while(cpu->pc!=0x05BF&&restartSteps++<50)c->step(c);
 require(cpu->pc==0x05BF&&cpu->sp==0xCFFE&&rd(c,0xFFAB)==0x16&&rd(c,0xFFAC)==0&&
         rd(c,0x4000)==0xAF&&cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800,
         "state9 maps A16 before external call",0);
 wr(c,0xCFFE,0xA6);wr(c,0xCFFF,3);cpu->pc=0x05C2;
 restartSteps=0;while(cpu->pc!=0x02B8&&restartSteps++<50)c->step(c);
 require(cpu->pc==0x02B8&&cpu->sp==0xD000&&cpu->a==0x11&&cpu->hl==0x03A6&&
         cpu->bc==0x1234&&cpu->de==0xBEEF,"state9 tail discards return before restart",0);
 /* Resident JP slots, stopped at target before executing its body. */
 for(unsigned entry=0x01BC;entry<0x02B8;entry+=3){
  unsigned target=rd(c,entry+1)|(rd(c,entry+2)<<8);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
  cpu->af=0x5AB0;cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;cpu->pc=entry;
  unsigned steps=0;while(cpu->pc!=target&&steps++<20)c->step(c);
  require(cpu->pc==target&&cpu->sp==0xCFFE&&cpu->af==0x5AB0&&cpu->bc==0x1234&&
          cpu->de==0xBEEF&&cpu->hl==0xD800,"resident JP preserves registers and stack",entry);
 }
 /* Banked dispatch prefixes only; separately force the restore tail. */
 for(unsigned window=0;window<2;window++)for(unsigned index=0;index<256;index++){
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
  unsigned previous=window?0x15:0x14,selectorShadow=window?0xFFAD:0xFFAB;
  unsigned typeShadow=selectorShadow+1,depth=window?0xC10F:0xC10E;
  unsigned stackBase=window?0xC10D:0xC107,slot=0x05C8+((index*3)&255);
  unsigned selected=rd(c,slot),target=rd(c,slot+1)|(rd(c,slot+2)<<8);
  wr(c,window?0x37FF:0x27FF,previous);wr(c,window?0x3800:0x2800,8);
  wr(c,selectorShadow,previous);wr(c,typeShadow,8);wr(c,depth,0);
  cpu->a=index;cpu->b=window;cpu->pc=0x23E4;
  unsigned stop=window?0x248C:0x2429,ret=window?0x248D:0x242A;
  unsigned steps=0;while(cpu->pc!=stop&&steps++<200)c->step(c);
  require(cpu->pc==stop&&cpu->hl==target&&cpu->de==target&&cpu->sp==0xCFFC&&
          rd(c,0xCFFC)==(ret&255)&&rd(c,0xCFFD)==(ret>>8)&&rd(c,depth)==1&&
          rd(c,selectorShadow)==selected&&rd(c,typeShadow)==0&&
          rd(c,stackBase)==previous&&rd(c,stackBase+1)==8,
          "banked dispatcher triple wrap prefix",window*256+index);
  /* Original target is not executed: start its restoration tail independently. */
  call(c,ret);
  require(rd(c,depth)==0&&rd(c,selectorShadow)==previous&&rd(c,typeShadow)==8&&
          rd(c,window?0xC115:0xC113)==previous&&rd(c,window?0xC116:0xC114)==8,
          "banked dispatcher forced restore tail",window*256+index);
 }
 /* Window-A helpers: eight explicit selector/type pairs, depth-free fields. */
 const unsigned helperSelectors[]={0,1,0x14,0x7F};
 for(unsigned type=0;type<2;type++)for(unsigned index=0;index<4;index++){
  unsigned selected=helperSelectors[index],savedType=type?8:0,slot=0xC650;
  wr(c,0x27FF,selected);wr(c,0x2800,savedType);wr(c,0xFFAB,selected);wr(c,0xFFAC,savedType);
  wr(c,0x37FF,0x15);wr(c,0x3800,0);wr(c,0xFFAD,0x15);wr(c,0xFFAE,0);
  cpu->bc=0x1234;cpu->hl=0xD800;cpu->de=slot;call(c,0x1783);
  require(rd(c,slot)==selected&&rd(c,slot+1)==savedType&&cpu->de==slot+1&&
          cpu->bc==0x1234&&cpu->hl==0xD800&&rd(c,0xFFAB)==0x16&&rd(c,0xFFAC)==0&&
          rd(c,0xC113)==0x16&&rd(c,0xC114)==0&&rd(c,0x4000)==0xAF&&rd(c,0xFFAD)==0x15,
          "save A fields and map native16",type*4+index);
  cpu->de=slot;call(c,0x179F);
  require(cpu->de==slot+1&&cpu->bc==0x1234&&cpu->hl==0xD800&&
          rd(c,0xFFAB)==selected&&rd(c,0xFFAC)==savedType&&rd(c,0xC113)==selected&&
          rd(c,0xC114)==savedType&&rd(c,0xFFAD)==0x15&&rd(c,0xFFAE)==0,
          "restore A fields without changing B",type*4+index);
 }
 /* Wrappers: stop before each target, then force its tail independently. */
 const unsigned wrapperEntries[]={0x1663,0x1675,0x1689,0x169D};
 const unsigned wrapperCallSites[]={0x166A,0x167C,0x1690,0x16A4};
 const unsigned wrapperTails[]={0x166D,0x167F,0x1693,0x16A7};
 for(unsigned index=0;index<4;index++){
  unsigned slot=0xC641+2*index;
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);wr(c,0x27FF,0x14);wr(c,0x2800,8);
  wr(c,0xFFAB,0x14);wr(c,0xFFAC,8);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->bc=0x1234;cpu->hl=0xD800;cpu->pc=wrapperEntries[index];
  unsigned steps=0;while(cpu->pc!=wrapperCallSites[index]&&steps++<100)c->step(c);
  require(cpu->pc==wrapperCallSites[index]&&cpu->sp==0xCFFE&&cpu->de==slot+1&&
          cpu->bc==0x1234&&cpu->hl==0xD800&&rd(c,slot)==0x14&&rd(c,slot+1)==8&&
          rd(c,0xFFAB)==0x16&&rd(c,0xFFAC)==0,
          "A16 wrapper prefix before external target",index);
  cpu->af=0x5AB0;call(c,wrapperTails[index]);
  require(rd(c,0xFFAB)==0x14&&rd(c,0xFFAC)==8&&cpu->de==slot+1&&
          cpu->bc==0x1234&&cpu->hl==0xD800&&(index==0?cpu->a==8:cpu->af==0x5AB0),
          "A16 wrapper independent tail and AF policy",index);
 }
 /* Positive-count copy cases: zero BC would wrap, not tested as empty. */
 const unsigned copyLengths[]={1,2,50,255,256};
 for(unsigned index=0;index<5;index++){
  unsigned count=copyLengths[index];wr(c,0x0000,0x0A);wr(c,0x0400,0);
  for(unsigned i=0;i<count;i++){wr(c,0xA500+i,(i*37+index)&255);wr(c,0xC900+i,0xA5);}
  wr(c,0xC8FF,0x5A);wr(c,0xC900+count,0x5A);
  cpu->hl=0xA500;cpu->de=0xC900;cpu->bc=count;call(c,0x2613);
  unsigned ok=1;for(unsigned i=0;i<count;i++)ok&=rd(c,0xC900+i)==((i*37+index)&255);
  require(ok&&cpu->hl==0xA500+count&&cpu->de==0xC900+count&&cpu->bc==0&&
          rd(c,0xC8FF)==0x5A&&rd(c,0xC900+count)==0x5A,"positive byte-copy boundaries",index);
 }
 /* Existing SYS0 only, full original wrappers/load-store/close/copy chain. */
 wr(c,0x0000,0x0A);wr(c,0x0400,0);wr(c,0x0800,1);wr(c,0xFFAF,0);wr(c,0xFFB0,1);
 for(unsigned i=0;i<0x30E;i++)wr(c,0xA000+i,0);
 wr(c,0xA002,0);wr(c,0xA003,0xA4);
 for(unsigned i=0;i<4;i++){wr(c,0xA004+i,rd(c,0x17B3+i));wr(c,0xA402+i,rd(c,0x17B3+i));}
 wr(c,0xA406,50);wr(c,0xA407,0);wr(c,0xA408,0);
 for(unsigned i=0;i<50;i++){wr(c,0xA409+i,(i*13+7)&255);wr(c,0xC700+i,0xA5);}
 wr(c,0x27FF,0x14);wr(c,0x2800,0);wr(c,0xFFAB,0x14);wr(c,0xFFAC,0);
 wr(c,0xFF40,0);call(c,0x1689);
 unsigned sysOK=1;for(unsigned i=0;i<50;i++)sysOK&=rd(c,0xC700+i)==((i*13+7)&255);
 require(sysOK&&cpu->a==0&&rd(c,0xFFAB)==0x14&&rd(c,0xFFAC)==0&&rd(c,0xA409)==255,
         "existing SYS0 full load chain and disabled SRAM",0);
 wr(c,0x0000,0x0A);wr(c,0x0400,0);wr(c,0x0800,1);
 unsigned sysSum=0;for(unsigned i=2;i<59;i++)sysSum+=rd(c,0xA400+i);
 require((rd(c,0xA400)|(rd(c,0xA401)<<8))==(sysSum&65535),"SYS0 load close checksum",0);
 for(unsigned i=0;i<50;i++)wr(c,0xC700+i,(255-i*3)&255);
 call(c,0x169D);unsigned sysResult=cpu->a;
 wr(c,0x0000,0x0A);wr(c,0x0400,0);wr(c,0x0800,1);
 sysOK=1;for(unsigned i=0;i<50;i++)sysOK&=rd(c,0xA409+i)==((255-i*3)&255);
 require(sysOK&&sysResult==0&&rd(c,0xFFAB)==0x14&&rd(c,0xFFAC)==0,
         "existing SYS0 full store chain",0);
 sysSum=0;for(unsigned i=2;i<59;i++)sysSum+=rd(c,0xA400+i);
 require((rd(c,0xA400)|(rd(c,0xA401)<<8))==(sysSum&65535),"SYS0 store close checksum",0);
 /* VBlank mapper prefix and separate restore tails, no A1E target. */
 const unsigned mapperModes[]={0,1,255};
 for(unsigned index=0;index<3;index++){
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
  wr(c,0xFFAB,0x14);wr(c,0xFFAC,0);wr(c,0xFFAD,0x15);wr(c,0xFFAE,0);
  wr(c,0x27FF,0x14);wr(c,0x2800,0);wr(c,0x37FF,0x15);wr(c,0x3800,0);
  wr(c,0xC663,0x15);wr(c,0xC664,0);wr(c,0xC672,mapperModes[index]);
  wr(c,0xCB81,0x10);wr(c,0xCB82,0);wr(c,0xCB83,0x11);wr(c,0xCB84,0);
  cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;cpu->pc=0x2242;
  unsigned steps=0;while(cpu->pc!=0x2264&&steps++<100)c->step(c);
  require(cpu->pc==0x2264&&cpu->sp==0xCFFE&&cpu->bc==0x1234&&cpu->de==0xBEEF&&
          cpu->hl==0xD800&&rd(c,0xC113)==0x1E&&rd(c,0xC114)==0&&rd(c,0xC115)==0x15&&
          rd(c,0xC116)==0&&rd(c,0x4000)==0xC3&&rd(c,0x6000)==0x1B&&rd(c,0xFFAB)==0x14,
          "VBlank mapper prefix before A1E call",index);
  call(c,0x2267);
  require(cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800&&
          rd(c,0xFFAB)==0x14&&rd(c,0xFFAC)==0&&rd(c,0xFFAD)==0x15&&rd(c,0xFFAE)==0&&
          rd(c,0x4000)==(index?0xEA:0x3E)&&rd(c,0x6000)==(index?0:0x1B)&&
          rd(c,0xC113)==(index?0x1E:0x14)&&rd(c,0xC114)==0&&rd(c,0xC115)==0x15&&rd(c,0xC116)==0,
          "VBlank mapper independent tails and shadow difference",index);
 }
 /* Native A1E tick: inactive global paths and one active slot at a time. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);wr(c,0xFFAB,0x1E);wr(c,0xFFAC,0);
 const unsigned tickCounts[]={0,1,2,255},tickRemainders[]={1,255};
 for(unsigned slot=0;slot<8;slot++)for(unsigned k=0;k<4;k++)for(unsigned rem=0;rem<2;rem++){
  for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
  unsigned base=0xCF00+slot*16,count=tickCounts[k],remaining=tickRemainders[rem];
  wr(c,base+1,1);wr(c,base+4,count);wr(c,base+5,remaining);
  cpu->bc=0x1234;call(c,0x4000);
  unsigned ok=1;for(unsigned other=0;other<8;other++)if(other!=slot)
   ok&=rd(c,0xCF01+other*16)==0&&rd(c,0xCF04+other*16)==0&&rd(c,0xCF05+other*16)==0;
  require(ok&&cpu->bc==0x1234&&rd(c,base+1)==1&&
          rd(c,base+4)==(count==1?255:((count-1)&255))&&
          rd(c,base+5)==(count==1?remaining-1:remaining),
          "A1E slot countdown wrap and remainder",slot*8+k*2+rem);
 }
 const unsigned tickCallSites[]={0x42C8,0x42E2,0x42FC,0x4316,0x4330,0x434A,0x4364,0x437E};
 for(unsigned slot=0;slot<8;slot++){
  for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
  wr(c,0xCF01+slot*16,1);wr(c,0xCF04+slot*16,1);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x4000;
  unsigned steps=0;while(cpu->pc!=tickCallSites[slot]&&steps++<300)c->step(c);
  require(cpu->pc==tickCallSites[slot]&&cpu->sp==0xCFFE&&rd(c,0xCF04+slot*16)==0&&
          rd(c,0xCF05+slot*16)==0,"A1E stops before external slot handler",slot);
 }
 const unsigned routeValues[]={0,1,15,16,0x55,0xAA,0xFE,255};
 const unsigned routeMasks[]={0,1,15,16,0x55,0x80,255};
 for(unsigned i=0;i<8;i++)for(unsigned j=0;j<7;j++){
  unsigned d=routeValues[i],e=routeMasks[j],swapped=((e<<4)|(e>>4))&255;
  wr(c,0xCF84,1);wr(c,0xCF88,d);wr(c,0xCF89,e);call(c,0x43A8);
  unsigned result=e?(e|((swapped^e^d)&255)):d;
  require(rd(c,0xFF25)==result,"A1E route-mask expression",i*7+j);
 }
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xFF25,0xA5);call(c,0x4000);
 require(rd(c,0xFF25)==0xA5,"A1E inactive slots and routing return",0);
 /* A1E global helpers: clear lower slots only, retain upper slots. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0xA5);
 cpu->de=0xBEEF;cpu->bc=0x1234;call(c,0x406E);
 unsigned lowerOK=1;for(unsigned i=0;i<0x90;i++){
  unsigned value=i<0x40||i==0x86||i==0x87||i==0x8A?0:0xA5;
  lowerOK&=rd(c,0xCF00+i)==value;
 }
 require(lowerOK&&cpu->hl==0xCF40&&cpu->bc==0x0034&&cpu->de==0xBEEF,
         "A1E clear leaves upper slots and adjacent globals intact",0);
 for(unsigned flagValue=0;flagValue<2;flagValue++)for(unsigned mask=0;mask<16;mask++){
  wr(c,0xFF26,0x80);wr(c,0xFF10,0x7F);wr(c,0xFF12,0xF3);wr(c,0xFF17,0xF2);
  wr(c,0xFF1A,0x80);wr(c,0xFF1C,0x60);wr(c,0xFF21,0xF1);
  for(unsigned slot=0;slot<4;slot++)wr(c,0xCF41+slot*16,(mask&(1<<slot))?(flagValue?255:1):0);
  call(c,0x4082);
  require((rd(c,0xFF10)&0x7F)==((mask&1)?0x7F:0)&&rd(c,0xFF12)==((mask&1)?0xF3:0)&&
          rd(c,0xFF17)==((mask&2)?0xF2:0)&&(rd(c,0xFF1A)&0x80)==((mask&4)?0x80:0)&&
          (rd(c,0xFF1C)&0x60)==((mask&4)?0x60:0)&&rd(c,0xFF21)==((mask&8)?0xF1:0),
          "A1E audio reset obeys upper-slot flags",flagValue*16+mask);
 }
 const unsigned globalCounts[]={0,1,2,255},globalPhases[]={0,14,15,255};
 for(unsigned periodIndex=0;periodIndex<2;periodIndex++)for(unsigned ci=0;ci<4;ci++)for(unsigned pi=0;pi<4;pi++){
  unsigned period=periodIndex?255:1,count=globalCounts[ci],phase=globalPhases[pi];
  for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
  wr(c,0xCF08,0xA5);wr(c,0xCF48,0x5A);wr(c,0xCF86,period);wr(c,0xCF87,count);wr(c,0xCF8A,phase);
  call(c,0x4000);
  unsigned reset=count==1&&phase==14;
  require(rd(c,0xCF86)==(reset?0:period)&&rd(c,0xCF87)==(reset?0:count==1?period:((count-1)&255))&&
          rd(c,0xCF8A)==(reset?0:count==1?((phase+1)&255):phase)&&
          rd(c,0xCF08)==(reset?0:0xA5)&&rd(c,0xCF48)==0x5A,
          "A1E integrated global tick expiry and wrap",periodIndex*16+ci*4+pi);
 }
 /* Slot0 opcode dispatch: stop before destination bodies or at sentinel. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned opcode=0;opcode<256;opcode++){
  wr(c,0xCF00,0);wr(c,0xCF01,0xD8);wr(c,0xD800,opcode);
  unsigned target=opcode<0x80?0xC100:opcode<0x90?0x4569:opcode<0xA0?0x44EB:
   opcode==0xB0?0x4479:opcode==0xB1?0x444D:opcode==0xC0?0x44C6:opcode==0xE0?0x4481:
   opcode==0xFD?0x4425:opcode==0xFE?0x4435:opcode==255?0x4A07:0xC100;
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);
  cpu->de=0xBEEF;cpu->pc=0x43E7;unsigned steps=0;
  while(cpu->pc!=target&&steps++<200)c->step(c);
  require(cpu->pc==target&&cpu->sp==(target==0xC100?0xD000:0xCFFE)&&cpu->bc==0xD801&&
          cpu->a==opcode&&cpu->de==0xBEEF&&rd(c,0xCF00)==0&&rd(c,0xCF01)==0xD8,
          "A1E slot0 all opcode dispatches",opcode);
 }
 const unsigned clampValues[]={0,1,14,15,16,127,128,255};
 for(unsigned active=0;active<2;active++)for(unsigned vi=0;vi<8;vi++)for(unsigned pi=0;pi<8;pi++){
  unsigned value=clampValues[vi],phase=clampValues[pi];wr(c,0xCF86,active);wr(c,0xCF8A,phase);
  cpu->a=value;cpu->bc=0x1234;cpu->de=0xBEEF;cpu->hl=0xD800;call(c,0x43CB);
  unsigned expected=active?(value<phase?0:value-phase):value;
  require(cpu->a==expected&&cpu->bc==0x1234&&cpu->de==0xBEEF&&cpu->hl==0xD800&&rd(c,0xCF8B)==value,
          "A1E phase clamp and register preservation",active*64+vi*8+pi);
 }
 const unsigned shortCounts[]={1,2,127},extendedPrefixes[]={0x80,0x81,0x82,255},extendedLow[]={0,127,128,255};
 for(unsigned index=0;index<19;index++){
  unsigned first=index<3?shortCounts[index]:extendedPrefixes[(index-3)/4];
  unsigned low=index<3?0:extendedLow[(index-3)%4];
  wr(c,0xCF00,0);wr(c,0xCF01,0xD8);wr(c,0xCF05,0x77);
  wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,first);wr(c,0xD803,low);
  call(c,0x43E7);
  require(rd(c,0xCF0D)==7&&rd(c,0xCF00)==(index<3?3:4)&&rd(c,0xCF01)==0xD8&&
          rd(c,0xCF04)==(index<3?first:(low|((first&1)<<7)))&&
          rd(c,0xCF05)==(index<3?0x77:((first&0x7F)>>1)),
          "A1E B0 short and extended countdown encoding",index);
 }
 const unsigned loopCounts[]={0,1,2,255};
 for(unsigned i=0;i<4;i++){
  wr(c,0xCF00,0);wr(c,0xCF01,0xD8);wr(c,0xD800,0xFD);wr(c,0xD801,loopCounts[i]);wr(c,0xD802,5);
  call(c,0x43E7);
  require(rd(c,0xCF0C)==loopCounts[i]&&rd(c,0xCF0A)==2&&rd(c,0xCF0B)==0xD8&&rd(c,0xCF04)==5,
          "A1E FD stores count and loop pointer",i);
  wr(c,0xCF00,0);wr(c,0xCF01,0xD8);wr(c,0xCF0C,loopCounts[i]);wr(c,0xCF0A,0x10);wr(c,0xCF0B,0xD8);
  wr(c,0xD800,0xFE);wr(c,0xD801,5);wr(c,0xD810,9);call(c,0x43E7);
  unsigned one=loopCounts[i]==1,stored=loopCounts[i]>1?loopCounts[i]-1:loopCounts[i];
  require(rd(c,0xCF0C)==stored&&rd(c,0xCF00)==(one?2:0x11)&&rd(c,0xCF04)==(one?5:9),
          "A1E FE count and pointer branches",i);
 }
 const unsigned b1Values[]={0,0x3F,0x40,0x41,255};
 for(unsigned i=0;i<5;i++){
  unsigned value=b1Values[i];wr(c,0xCF00,0);wr(c,0xCF01,0xD8);wr(c,0xCF88,0xA5);
  wr(c,0xD800,0xB1);wr(c,0xD801,value);wr(c,0xD802,1);call(c,0x43E7);
  require(rd(c,0xCF88)==(value<0x40?0xB4:value==0x40?0xB5:0xA5)&&rd(c,0xCF28)==(value==0x40?0:255),
          "A1E B1 threshold bit edits",i);
 }
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xCF00,0);wr(c,0xCF01,0xD8);wr(c,0xCF04,1);
 wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,5);call(c,0x4000);
 require(rd(c,0xCF0D)==7&&rd(c,0xCF04)==5&&rd(c,0xCF00)==3&&rd(c,0xCF01)==0xD8,
         "A1E integrated tick invokes slot0 B0 handler",0);
 /* Slot1 opcode dispatch, measured from its original distinct destinations. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned opcode=0;opcode<256;opcode++){
  wr(c,0xCF10,0);wr(c,0xCF11,0xD8);wr(c,0xD800,opcode);
  unsigned target=opcode<0x80?0xC100:opcode<0x90?0x471A:opcode<0xA0?0x46A1:
   opcode==0xB0?0x4607:opcode==0xB1?0x460F:opcode==0xC0?0x4682:opcode==0xE0?0x463D:
   opcode==0xFD?0x45DF:opcode==0xFE?0x45EF:opcode==255?0x4A07:0xC100;
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);
  cpu->de=0xBEEF;cpu->pc=0x45A1;unsigned steps=0;while(cpu->pc!=target&&steps++<200)c->step(c);
  require(cpu->pc==target&&cpu->sp==(target==0xC100?0xD000:0xCFFE)&&cpu->bc==0xD801&&
          cpu->a==opcode&&cpu->de==0xBEEF&&rd(c,0xCF10)==0&&rd(c,0xCF11)==0xD8,
          "A1E slot1 all opcode dispatches",opcode);
 }
 for(unsigned index=0;index<19;index++){
  unsigned first=index<3?shortCounts[index]:extendedPrefixes[(index-3)/4];
  unsigned low=index<3?0:extendedLow[(index-3)%4];
  wr(c,0xCF10,0);wr(c,0xCF11,0xD8);wr(c,0xCF15,0x77);wr(c,0xCF04,0xA5);
  wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,first);wr(c,0xD803,low);call(c,0x45A1);
  require(rd(c,0xCF1D)==7&&rd(c,0xCF10)==(index<3?3:4)&&rd(c,0xCF11)==0xD8&&
          rd(c,0xCF14)==(index<3?first:(low|((first&1)<<7)))&&
          rd(c,0xCF15)==(index<3?0x77:((first&0x7F)>>1))&&rd(c,0xCF04)==0xA5,
          "A1E slot1 B0 countdown preserves other slot",index);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF10,0);wr(c,0xCF11,0xD8);wr(c,0xCF88,0xA5);wr(c,0xCF28,0x37);
  wr(c,0xD800,0xB1);wr(c,0xD801,value);wr(c,0xD802,1);call(c,0x45A1);
  require(rd(c,0xCF88)==(value<0x40?0xA5:value==0x40?0xA7:0x87)&&
          rd(c,0xCF19)==(value==0x40?0:255)&&rd(c,0xCF28)==0x37,
          "A1E slot1 B1 bit1 bit5 and own field",value);
 }
 for(unsigned i=0;i<66;i++)wr(c,0xD900+i,(i*7+1)&255);
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF10,0);wr(c,0xCF11,0xD8);wr(c,0xCF96,0);wr(c,0xCF97,0xD9);
  wr(c,0xD800,0xC0);wr(c,0xD801,value);wr(c,0xD802,3);call(c,0x45A1);
  unsigned offset=2*((value&31)+1);
  require(rd(c,0xCF17)==((offset*7+1)&255)&&rd(c,0xCF18)==(((offset+1)*7+1)&255)&&
          rd(c,0xCF10)==3&&rd(c,0xCF11)==0xD8&&rd(c,0xCF14)==3,
          "A1E slot1 C0 masked two-byte records",value);
 }
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xCF10,0);wr(c,0xCF11,0xD8);wr(c,0xCF14,1);
 wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,5);call(c,0x4000);
 require(rd(c,0xCF1D)==7&&rd(c,0xCF14)==5&&rd(c,0xCF10)==3&&rd(c,0xCF11)==0xD8,
         "A1E integrated tick invokes slot1 B0",0);
 /* Slot2 distinct routing bits and wave-pointer table, synthetic streams. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned opcode=0;opcode<256;opcode++){
  wr(c,0xCF20,0);wr(c,0xCF21,0xD8);wr(c,0xD800,opcode);
  unsigned target=opcode<0x80?0xC100:opcode<0x90?0x48DF:opcode<0xA0?0x484F:
   opcode==0xB0?0x47D8:opcode==0xB1?0x47B8:opcode==0xC0?0x4825:opcode==0xE0?0x47E0:
   opcode==0xFD?0x4790:opcode==0xFE?0x47A0:opcode==255?0x4A07:0xC100;
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);
  cpu->de=0xBEEF;cpu->pc=0x4752;unsigned steps=0;while(cpu->pc!=target&&steps++<200)c->step(c);
  require(cpu->pc==target&&cpu->sp==(target==0xC100?0xD000:0xCFFE)&&cpu->bc==0xD801&&
          cpu->a==opcode&&cpu->de==0xBEEF&&rd(c,0xCF20)==0&&rd(c,0xCF21)==0xD8,
          "A1E slot2 all opcode dispatches",opcode);
 }
 for(unsigned index=0;index<19;index++){
  unsigned first=index<3?shortCounts[index]:extendedPrefixes[(index-3)/4];
  unsigned low=index<3?0:extendedLow[(index-3)%4];
  wr(c,0xCF20,0);wr(c,0xCF21,0xD8);wr(c,0xCF25,0x77);wr(c,0xCF14,0xA5);
  wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,first);wr(c,0xD803,low);call(c,0x4752);
  require(rd(c,0xCF2D)==7&&rd(c,0xCF20)==(index<3?3:4)&&rd(c,0xCF21)==0xD8&&
          rd(c,0xCF24)==(index<3?first:(low|((first&1)<<7)))&&
          rd(c,0xCF25)==(index<3?0x77:((first&0x7F)>>1))&&rd(c,0xCF14)==0xA5,
          "A1E slot2 B0 countdown preserves slot1",index);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF20,0);wr(c,0xCF21,0xD8);wr(c,0xCF88,0x2A);wr(c,0xCF19,0x37);
  wr(c,0xD800,0xB1);wr(c,0xD801,value);wr(c,0xD802,1);call(c,0x4752);
  require(rd(c,0xCF88)==(value<0x40?0x6A:value==0x40?0x6E:0x2E)&&rd(c,0xCF19)==0x37,
          "A1E slot2 B1 bits2 and6",value);
 }
 for(unsigned index=0;index<32;index++){
  unsigned pointer=0xDA00+index*16;wr(c,0xD900+index*2,pointer&255);wr(c,0xD901+index*2,pointer>>8);
  for(unsigned i=0;i<16;i++)wr(c,pointer+i,(index*7+i*13+1)&255);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xFF1A,0);wr(c,0xCF20,0);wr(c,0xCF21,0xD8);wr(c,0xCF98,0);wr(c,0xCF99,0xD9);
  wr(c,0xD800,0xC0);wr(c,0xD801,value);wr(c,0xD802,3);call(c,0x4752);
  bool wave=true;for(unsigned i=0;i<16;i++)if(rd(c,0xFF30+i)!=(((value&31)*7+i*13+1)&255))wave=false;
  require(wave&&rd(c,0xCF27)==(value&31)&&rd(c,0xCF20)==3&&rd(c,0xCF21)==0xD8&&rd(c,0xCF24)==3,
          "A1E slot2 C0 masked pointers copy16 wave bytes",value);
 }
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xCF20,0);wr(c,0xCF21,0xD8);wr(c,0xCF24,1);
 wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,5);call(c,0x4000);
 require(rd(c,0xCF2D)==7&&rd(c,0xCF24)==5&&rd(c,0xCF20)==3&&rd(c,0xCF21)==0xD8,
         "A1E integrated tick invokes slot2 B0",0);
 /* Slot3 supports B1/C0 and loop commands; B0/E0 return as unknown. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned opcode=0;opcode<256;opcode++){
  wr(c,0xCF30,0);wr(c,0xCF31,0xD8);wr(c,0xD800,opcode);
  unsigned target=opcode<0x80?0xC100:opcode<0x90?0x49E4:opcode<0xA0?0x4979:
   opcode==0xB1?0x4948:opcode==0xC0?0x4974:opcode==0xFD?0x4920:
   opcode==0xFE?0x4930:opcode==255?0x4A07:0xC100;
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);
  cpu->de=0xBEEF;cpu->pc=0x48EC;unsigned steps=0;while(cpu->pc!=target&&steps++<200)c->step(c);
  require(cpu->pc==target&&cpu->sp==(target==0xC100?0xD000:0xCFFE)&&cpu->bc==0xD801&&
          cpu->a==opcode&&cpu->de==0xBEEF&&rd(c,0xCF30)==0&&rd(c,0xCF31)==0xD8,
          "A1E slot3 all opcode dispatches",opcode);
 }
 for(unsigned index=0;index<19;index++){
  unsigned first=index<3?shortCounts[index]:extendedPrefixes[(index-3)/4];
  unsigned low=index<3?0:extendedLow[(index-3)%4];
  wr(c,0xCF30,0);wr(c,0xCF31,0xD8);wr(c,0xCF35,0x77);wr(c,0xCF24,0xA5);
  wr(c,0xD800,0xC0);wr(c,0xD801,7);wr(c,0xD802,first);wr(c,0xD803,low);call(c,0x48EC);
  require(rd(c,0xCF30)==(index<3?3:4)&&rd(c,0xCF31)==0xD8&&
          rd(c,0xCF34)==(index<3?first:(low|((first&1)<<7)))&&
          rd(c,0xCF35)==(index<3?0x77:((first&0x7F)>>1))&&rd(c,0xCF24)==0xA5,
          "A1E slot3 C0 countdown preserves slot2",index);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF30,0);wr(c,0xCF31,0xD8);wr(c,0xCF88,0x25);wr(c,0xCF19,0x37);
  wr(c,0xD800,0xB1);wr(c,0xD801,value);wr(c,0xD802,1);call(c,0x48EC);
  require(rd(c,0xCF88)==(value<0x40?0xA5:value==0x40?0xAD:0x2D)&&
          rd(c,0xCF39)==(value==0x40?0:255)&&rd(c,0xCF19)==0x37,
          "A1E slot3 B1 bits3 and7 own field",value);
 }
 for(unsigned value=0;value<256;value++){
  for(unsigned i=2;i<16;i++)wr(c,0xCF30+i,0x50+i);
  wr(c,0xCF30,0);wr(c,0xCF31,0xD8);wr(c,0xD800,0xC0);wr(c,0xD801,value);wr(c,0xD802,3);
  call(c,0x48EC);bool fields=true;for(unsigned i=2;i<16;i++)if(i!=4&&rd(c,0xCF30+i)!=0x50+i)fields=false;
  require(fields&&rd(c,0xCF30)==3&&rd(c,0xCF31)==0xD8&&rd(c,0xCF34)==3,
          "A1E slot3 C0 skips parameter without field writes",value);
 }
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xCF30,0);wr(c,0xCF31,0xD8);wr(c,0xCF34,1);
 wr(c,0xD800,0xC0);wr(c,0xD801,7);wr(c,0xD802,5);call(c,0x4000);
 require(rd(c,0xCF34)==5&&rd(c,0xCF30)==3&&rd(c,0xCF31)==0xD8,
         "A1E integrated tick invokes slot3 C0",0);
 const unsigned lowerHandlers[]={0x43E7,0x45A1,0x4752,0x48EC};
 for(unsigned slot=0;slot<4;slot++){
  for(unsigned i=0;i<0x80;i++)wr(c,0xCF00+i,0x5A);
  wr(c,0xCF00+slot*16,0);wr(c,0xCF01+slot*16,0xD8);wr(c,0xD800,255);call(c,lowerHandlers[slot]);
  bool exact=true;for(unsigned i=0;i<0x80;i++)if(rd(c,0xCF00+i)!=(i/16==slot?0:0x5A))exact=false;
  require(exact&&cpu->hl==0xCF10+slot*16&&cpu->b==0&&cpu->a==0,
          "A1E FF clears exact16 bytes for each lower slot",slot);
 }
 /* Upper slot4: all sub90 opcodes take its audio tail, not early return. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned opcode=0;opcode<256;opcode++){
  wr(c,0xCF40,0);wr(c,0xCF41,0xD8);wr(c,0xD800,opcode);
  unsigned target=opcode<0x90?0x4CF1:opcode<0xA0?0x4C83:
   opcode==0xB0?0x4C3D:opcode==0xB1?0x4C1F:opcode==0xC0?0x4BFA:opcode==0xE0?0x4C45:
   opcode==0xFD?0x4BD2:opcode==0xFE?0x4BE2:opcode==255?0x4BC8:0xC100;
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);
  cpu->de=0xBEEF;cpu->pc=0x4B90;unsigned steps=0;while(cpu->pc!=target&&steps++<200)c->step(c);
  require(cpu->pc==target&&cpu->sp==(target==0xC100?0xD000:0xCFFE)&&cpu->bc==0xD801&&
          cpu->a==opcode&&cpu->de==0xBEEF&&rd(c,0xCF40)==0&&rd(c,0xCF41)==0xD8,
          "A1E slot4 all opcode dispatches",opcode);
 }
 for(unsigned index=0;index<19;index++){
  unsigned first=index<3?shortCounts[index]:extendedPrefixes[(index-3)/4];
  unsigned low=index<3?0:extendedLow[(index-3)%4];
  wr(c,0xCF40,0);wr(c,0xCF41,0xD8);wr(c,0xCF45,0x77);wr(c,0xCF34,0xA5);
  wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,first);wr(c,0xD803,low);call(c,0x4B90);
  require(rd(c,0xCF4D)==7&&rd(c,0xCF40)==(index<3?3:4)&&rd(c,0xCF41)==0xD8&&
          rd(c,0xCF44)==(index<3?first:(low|((first&1)<<7)))&&
          rd(c,0xCF45)==(index<3?0x77:((first&0x7F)>>1))&&rd(c,0xCF34)==0xA5,
          "A1E slot4 B0 countdown preserves slot3",index);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF40,0);wr(c,0xCF41,0xD8);wr(c,0xCF89,0x2A);wr(c,0xCF88,0x37);
  wr(c,0xD800,0xB1);wr(c,0xD801,value);wr(c,0xD802,1);call(c,0x4B90);
  require(rd(c,0xCF89)==(value<0x40?0x3A:value==0x40?0x3B:0x2B)&&rd(c,0xCF88)==0x37,
          "A1E slot4 B1 bits0 and4 in CF89",value);
 }
 for(unsigned i=0;i<99;i++)wr(c,0xD900+i,(i*7+1)&255);
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF40,0);wr(c,0xCF41,0xD8);wr(c,0xCF94,0);wr(c,0xCF95,0xD9);
  wr(c,0xD800,0xC0);wr(c,0xD801,value);wr(c,0xD802,3);call(c,0x4B90);
  unsigned offset=3*((value&31)+1);
  require(rd(c,0xCF47)==((offset*7+1)&255)&&rd(c,0xCF48)==(((offset+1)*7+1)&255)&&
          rd(c,0xCF49)==(((offset+2)*7+1)&255)&&rd(c,0xCF40)==3&&rd(c,0xCF41)==0xD8&&rd(c,0xCF44)==3,
          "A1E slot4 C0 masked three-byte records",value);
 }
 const unsigned loopCounts4[]={0,1,2,255};
 for(unsigned index=0;index<4;index++){
  unsigned count=loopCounts4[index];wr(c,0xCF40,0);wr(c,0xCF41,0xD8);
  wr(c,0xCF4C,count);wr(c,0xCF0C,0x77);wr(c,0xCF4A,0);wr(c,0xCF4B,0xD9);
  wr(c,0xD800,0xFE);wr(c,0xD801,5);wr(c,0xD900,3);call(c,0x4B90);
  require(rd(c,0xCF4C)==count&&rd(c,0xCF0C)==(count>1?count-1:0x77)&&
          rd(c,0xCF40)==(count==1?2:1)&&rd(c,0xCF41)==(count==1?0xD8:0xD9)&&rd(c,0xCF44)==(count==1?5:3),
          "A1E slot4 FE retains own count writes CF0C",index);
 }
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xCF40,0);wr(c,0xCF41,0xD8);wr(c,0xCF44,1);
 wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,5);call(c,0x4000);
 require(rd(c,0xCF4D)==7&&rd(c,0xCF44)==5&&rd(c,0xCF40)==3&&rd(c,0xCF41)==0xD8,
         "A1E integrated tick invokes slot4 B0",0);
 /* Upper slot5: all sub90 opcodes take its audio tail, not early return. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned opcode=0;opcode<256;opcode++){
  wr(c,0xCF50,0);wr(c,0xCF51,0xD8);wr(c,0xD800,opcode);
  unsigned target=opcode<0x90?0x4E78:opcode<0xA0?0x4E11:
   opcode==0xB0?0x4DAD:opcode==0xB1?0x4DF3:opcode==0xC0?0x4D8D:opcode==0xE0?0x4DB5:
   opcode==0xFD?0x4D65:opcode==0xFE?0x4D75:opcode==255?0x4D5B:0xC100;
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);
  cpu->de=0xBEEF;cpu->pc=0x4D23;unsigned steps=0;while(cpu->pc!=target&&steps++<200)c->step(c);
  require(cpu->pc==target&&cpu->sp==(target==0xC100?0xD000:0xCFFE)&&cpu->bc==0xD801&&
          cpu->a==opcode&&cpu->de==0xBEEF&&rd(c,0xCF50)==0&&rd(c,0xCF51)==0xD8,
          "A1E slot5 all opcode dispatches",opcode);
 }
 for(unsigned index=0;index<19;index++){
  unsigned first=index<3?shortCounts[index]:extendedPrefixes[(index-3)/4];
  unsigned low=index<3?0:extendedLow[(index-3)%4];
  wr(c,0xCF50,0);wr(c,0xCF51,0xD8);wr(c,0xCF55,0x77);wr(c,0xCF44,0xA5);
  wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,first);wr(c,0xD803,low);call(c,0x4D23);
  require(rd(c,0xCF5D)==7&&rd(c,0xCF50)==(index<3?3:4)&&rd(c,0xCF51)==0xD8&&
          rd(c,0xCF54)==(index<3?first:(low|((first&1)<<7)))&&
          rd(c,0xCF55)==(index<3?0x77:((first&0x7F)>>1))&&rd(c,0xCF44)==0xA5,
          "A1E slot5 B0 countdown preserves slot4",index);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF50,0);wr(c,0xCF51,0xD8);wr(c,0xCF89,0x2A);wr(c,0xCF88,0x37);
  wr(c,0xD800,0xB1);wr(c,0xD801,value);wr(c,0xD802,1);call(c,0x4D23);
  require(rd(c,0xCF89)==(value<0x40?0x28:value==0x40?0x2A:0x0A)&&rd(c,0xCF88)==0x37,
          "A1E slot5 B1 bits1 and5 in CF89",value);
 }
 for(unsigned i=0;i<66;i++)wr(c,0xD900+i,(i*7+1)&255);
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF50,0);wr(c,0xCF51,0xD8);wr(c,0xCF96,0);wr(c,0xCF97,0xD9);
  wr(c,0xD800,0xC0);wr(c,0xD801,value);wr(c,0xD802,3);call(c,0x4D23);
  unsigned offset=2*((value&31)+1);
  require(rd(c,0xCF57)==((offset*7+1)&255)&&rd(c,0xCF58)==(((offset+1)*7+1)&255)&&
          rd(c,0xCF50)==3&&rd(c,0xCF51)==0xD8&&rd(c,0xCF54)==3,
          "A1E slot5 C0 masked two-byte records",value);
 }
 const unsigned loopCounts5[]={0,1,2,255};
 for(unsigned index=0;index<4;index++){
  unsigned count=loopCounts5[index];wr(c,0xCF50,0);wr(c,0xCF51,0xD8);
  wr(c,0xCF5C,count);wr(c,0xCF0C,0x77);wr(c,0xCF5A,0);wr(c,0xCF5B,0xD9);
  wr(c,0xD800,0xFE);wr(c,0xD801,5);wr(c,0xD900,3);call(c,0x4D23);
  require(rd(c,0xCF5C)==(count>1?count-1:count)&&rd(c,0xCF0C)==0x77&&
          rd(c,0xCF50)==(count==1?2:1)&&rd(c,0xCF51)==(count==1?0xD8:0xD9)&&rd(c,0xCF54)==(count==1?5:3),
          "A1E slot5 FE updates own count retains CF0C",index);
 }
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xCF50,0);wr(c,0xCF51,0xD8);wr(c,0xCF54,1);
 wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,5);call(c,0x4000);
 require(rd(c,0xCF5D)==7&&rd(c,0xCF54)==5&&rd(c,0xCF50)==3&&rd(c,0xCF51)==0xD8,
         "A1E integrated tick invokes slot5 B0",0);
 printf("PASS SYNTHETIC storage probes: %u assertions; version=%s commit=%s\n",
        checks,projectVersion,gitCommit);
 c->unloadROM(c);mCoreConfigDeinit(&c->config);c->deinit(c);return 0;
}
