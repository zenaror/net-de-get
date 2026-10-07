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
 printf("PASS SYNTHETIC storage probes: %u assertions; version=%s commit=%s\n",
        checks,projectVersion,gitCommit);
 c->unloadROM(c);mCoreConfigDeinit(&c->config);c->deinit(c);return 0;
}
