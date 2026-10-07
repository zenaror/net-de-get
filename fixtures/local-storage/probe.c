/* SYNTHETIC CPU probes. No natural launch, flash write or disk save. */
#include <mgba/flags.h>
#include <mgba/core/core.h>
#include <mgba/core/config.h>
#include <mgba/core/version.h>
#include <mgba/internal/gb/gb.h>
#include <mgba/internal/sm83/sm83.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static unsigned checks;
static void require(int ok,const char *name,unsigned index){
 if(!ok){fprintf(stderr,"FAIL %s case=%u\n",name,index);exit(10);}checks++;
}
/* Independent wrapped-threshold oracle; no natural character names asserted. */
static unsigned markerModel(unsigned b,unsigned c,unsigned e,unsigned *d,unsigned *flags){
 #define MARKER_CP(v) do{*d=(b+(v))&255;*flags=0x40|(c==*d?0x80:0)|((c&15)<(*d&15)?0x20:0)|(c<*d?0x10:0);}while(0)
 if(e<255){
  if(b){MARKER_CP(0x85);if(c==*d)return 1;}
  MARKER_CP(0x96);if(c==*d)return 0;
  MARKER_CP(0x8A);if(c<*d)return 0;
  MARKER_CP(0x9A);if(c<*d)return 1;
 }
 MARKER_CP(0x9F);if(c<*d)return 0;
 MARKER_CP(0xA4);return c<*d;
 #undef MARKER_CP
}
static void wr(struct mCore *c,unsigned address,unsigned value){c->busWrite8(c,address,value);}
static unsigned rd(struct mCore *c,unsigned address){return c->busRead8(c,address);}
/* Schedule before HALT: the core processes this event inside its wait loop.
   IME stays false; this is a fixture producer, not a natural IRQ/frame trace. */
struct SyntheticWake {struct mTimingEvent event;struct mCore *core;bool fired,wasHalted;bool setFlag;};
static void syntheticWakeEvent(struct mTiming *timing,void *context,uint32_t late){
 (void)timing;(void)late;struct SyntheticWake *wake=context;
 wake->wasHalted=((struct GB*)wake->core->board)->cpu->halted;wake->fired=true;
 if(wake->setFlag)wr(wake->core,0xFF8A,1);
 wr(wake->core,0xFFFF,1);wr(wake->core,0xFF0F,1);
}
static bool wakeSyntheticHalt(struct mCore *c,bool setFlag){
 struct GB *g=c->board;struct SyntheticWake wake={0};wake.core=c;wake.setFlag=setFlag;
 wake.event.context=&wake;wake.event.callback=syntheticWakeEvent;wake.event.name="synthetic frame wake";wake.event.priority=0x80;
 mTimingSchedule(&g->timing,&wake.event,64);
 unsigned steps=0;while(!wake.fired&&steps++<1000)c->step(c);
 mTimingDeschedule(&g->timing,&wake.event);
 wr(c,0xFF0F,0);wr(c,0xFFFF,0);
 return wake.fired&&wake.wasHalted&&!g->cpu->halted&&!g->memory.ime;
}
static void callWithLimit(struct mCore *c,unsigned entry,unsigned limit){
 struct GB *g=c->board;struct SM83Core *cpu=g->cpu;
 wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;
 cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
 wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=entry;
 unsigned steps=0;while(cpu->pc!=0xC100&&steps++<limit)c->step(c);
 require(cpu->pc==0xC100&&cpu->sp==0xD000,"bounded return",entry);
}
static void call(struct mCore *c,unsigned entry){callWithLimit(c,entry,100000);}
/* Independent quotient/remainder model, including the original zero-divisor result. */
static void probeSelectionFields(struct mCore *c,unsigned pointer,unsigned b,unsigned divisorC,unsigned inputD,unsigned divisorE,unsigned flags,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;
 unsigned q1=divisorE?inputD/divisorE:255,r1=divisorE?inputD%divisorE:inputD;
 unsigned q2=divisorC?q1/divisorC:255,r2=divisorC?q1%divisorC:q1;
 unsigned fieldC217=(q2+(r2!=0))&255,fieldC211=r2?(r2+(r1!=0))&255:divisorC;
 for(unsigned a=0xC209;a<=0xC21C;a++)wr(c,a,0xA5);
 cpu->hl=pointer;cpu->bc=b<<8|divisorC;cpu->de=inputD<<8|divisorE;cpu->a=0x5A;cpu->f.packed=flags;
 call(c,0x1F2);
 unsigned expected[]={pointer&255,pointer>>8,0xA5,b,divisorC,inputD,divisorE,fieldC211,0,0,0,255,255,fieldC217,0xA5,0xA5,0xA5,0,0xA5};
 bool fields=rd(c,0xC209)==0xA5;for(unsigned i=0;i<sizeof(expected)/sizeof(expected[0]);i++)fields&=rd(c,0xC20A+i)==expected[i];
 require(fields,"Original selection initializer fields quotient branches and adjacent guards",index);
 require(cpu->a==255&&cpu->f.packed==0x80&&cpu->bc==(r2?divisorE:divisorC)&&cpu->de==(q1<<8|divisorE)&&cpu->hl==0xC217,
  "Original selection initializer complete register contract",index);
}
struct SelectionModel {unsigned rows,columns,lastRows,pages,page,row,col,limit;};
static unsigned rol3(unsigned x){x&=255;return ((x<<3)|(x>>5))&255;}
static void probeSelectionInput(struct mCore *c,struct SelectionModel old,unsigned repeat,unsigned edge,unsigned mode,unsigned frame,unsigned capacity,bool callback,unsigned index){
 struct GB *g=c->board;struct SM83Core *cpu=g->cpu;struct SelectionModel next=old;
 unsigned sound=0,redraw=0,active=1;
 if(repeat&0x40){sound=old.limit>=((old.columns+1)&255)?0x9B:0;
  if(old.row)next.row=(old.row-1)&255;
  else if(old.pages==1)next.row=(old.lastRows-1)&255;
  else if(old.page){next.page=(old.page-1)&255;next.row=(old.rows-1)&255;redraw=1;}
 }else if(repeat&0x80){sound=old.limit>=((old.columns+1)&255)?0x9B:0;
  if(old.page==((old.pages-1)&255)){if(old.row!=((old.lastRows-1)&255))next.row=(old.row+1)&255;else if(old.pages==1)next.row=0;}
  else if(((old.rows-1-old.row)&255)!=0)next.row=(old.row+1)&255;
  else{if(((old.pages-1-old.page)&255)!=0){next.page=(old.page+1)&255;next.row=0;}redraw=1;}
 }else if(repeat&0x20){sound=old.columns>=2?0x9C:0;next.col=old.col?(old.col-1)&255:(old.columns-1)&255;
 }else if(repeat&0x10){sound=old.columns>=2?0x9C:0;next.col=old.col<((old.columns-1)&255)?(old.col+1)&255:0;
 }else if(edge&1){next.row=(old.page*old.rows*old.columns+old.row*old.columns+old.col)&255;active=0;}
 unsigned records[4][4],count=0,notify=0;
 #define SELECTION_REC(x,y,t) do{records[count][0]=(x)&255;records[count][1]=(y)&255;records[count][2]=255;records[count++][3]=(t);}while(0)
 if(active){unsigned x=8+rol3(next.col*2),y=(2*next.row+4)*8,tile=0x76+((frame>>3)&1);
  if(mode==0){SELECTION_REC(x,y,tile);SELECTION_REC(rol3(2)+rol3(next.col*2),y,tile);}
  else{int jitter=(int)(((frame>>2)&3)^3)-2;SELECTION_REC(x+jitter,y,tile);}
  bool early=false;
  if(next.page){if(!(frame&16))early=true;else{SELECTION_REC(81,24,0x7C);}}
  if(!early&&next.page!=((next.pages-1)&255)){if(!(frame&16))early=true;else{SELECTION_REC(81,80,0x7D);}}
  notify=!early&&next.row!=255;
 }
 #undef SELECTION_REC
 wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0xFF4F,0);
 wr(c,0x27FF,0x0F);wr(c,0x2800,0);wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);wr(c,0xC113,0x0F);wr(c,0xC114,0);
 wr(c,0x37FF,5);wr(c,0x3800,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);wr(c,0xC115,5);wr(c,0xC116,0);
 unsigned aBytes[8],bBytes[8];for(unsigned i=0;i<8;i++){aBytes[i]=rd(c,0x4000+i);bBytes[i]=rd(c,0x6000+i);}
 wr(c,0xC663,0x14);wr(c,0xC664,0);wr(c,0xCF92,0);wr(c,0xCF93,0xD3);wr(c,0xCF82,0x55);wr(c,0xCF89,0);
 for(unsigned i=0;i<128;i++){wr(c,0xD300+2*i,0x10);wr(c,0xD301+2*i,0xD6);}wr(c,0xD610,0);
 for(unsigned i=0;i<256;i++)wr(c,0xD800+i,0);
 const unsigned cb[]={0xFA,0x20,0xD9,0x3C,0xEA,0x20,0xD9,0xC9};for(unsigned i=0;i<8;i++)wr(c,0xD900+i,cb[i]);wr(c,0xD920,0);
 wr(c,0xC1A3,0x23);wr(c,0xC1A4,1);wr(c,0xC1A7,2);wr(c,0xC1A8,8);wr(c,0xC1A9,4);wr(c,0xC1AA,1);wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1B9,0);
 wr(c,0xC1C4,capacity);wr(c,0xC1C9,0x3C);for(unsigned i=0;i<64;i++)wr(c,0xC1CA+i,0xA5);
 wr(c,0xC20A,0);wr(c,0xC20B,0xD8);wr(c,0xC20D,0);wr(c,0xC20E,old.rows);wr(c,0xC20F,old.limit);wr(c,0xC210,old.columns);
 wr(c,0xC211,old.lastRows);wr(c,0xC212,old.page);wr(c,0xC213,1);wr(c,0xC214,old.row);wr(c,0xC215,0xA5);wr(c,0xC216,255);wr(c,0xC217,old.pages);wr(c,0xC218,mode);wr(c,0xC219,0);wr(c,0xC21A,callback?0xD9:0);wr(c,0xC21B,old.col);wr(c,0xC21C,0x5A);
 wr(c,0xFF98,repeat);wr(c,0xFF97,edge);wr(c,0xFF8B,frame);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
 cpu->af=0x5AF0;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x1F8;
 unsigned steps=0,sounds=0,soundCode=0,draws=0,callbacks=0;
 while(cpu->pc!=0xC100&&steps++<100000){if(cpu->pc==0x24F){sounds++;soundCode=cpu->a;}if(cpu->pc==0x30BC)draws++;if(cpu->pc==0xD900)callbacks++;c->step(c);}
 require(cpu->pc==0xC100&&cpu->sp==0xD000,"Selection input traced bounded complete return",index);
 bool exact=rd(c,0xC212)==next.page&&rd(c,0xC214)==next.row&&rd(c,0xC21B)==next.col&&rd(c,0xC213)==active&&rd(c,0xC215)==old.page&&rd(c,0xC216)==(notify?next.row:255)&&
  sounds==(sound!=0)&&soundCode==sound&&draws==redraw&&callbacks==(notify&&callback)&&rd(c,0xD920)==(notify&&callback)&&rd(c,0xCF82)==(sound?0:0x55)&&
  rd(c,0xC21C)==0x5A&&rd(c,0xC1C9)==0x3C&&rd(c,0xC20A)==0&&rd(c,0xC20B)==0xD8&&rd(c,0xC113)==0x0F&&rd(c,0xC114)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0;
 for(unsigned i=0;i<8;i++){exact&=rd(c,0x4000+i)==aBytes[i];exact&=rd(c,0x6000+i)==bBytes[i];}
 if(!exact)fprintf(stderr,"Selection input case=%u repeat=%02X edge=%02X page=%u/%u row=%u/%u col=%u/%u sounds=%u/%u draw=%u/%u cb=%u/%u\n",index,repeat,edge,rd(c,0xC212),next.page,rd(c,0xC214),next.row,rd(c,0xC21B),next.col,sounds,sound,draws,redraw,callbacks,notify&&callback);
 require(exact,"Selection input independent priority state redraw sound actual callback mapper guards",index);
 unsigned accepted=capacity<16?(count<16-capacity?count:16-capacity):0;
 exact=rd(c,0xC1C4)==capacity+accepted;for(unsigned i=0;i<64;i++){unsigned entry=i/4,expected=entry>=capacity&&entry<capacity+accepted?records[entry-capacity][i%4]:0xA5;exact&=rd(c,0xC1CA+i)==expected;}
 require(exact,"Selection input whole descriptor queue blink arrows jitter capacity guards",index);
}
/* Independent byte-state model, including the core's explicit opposing-key policy. */
struct JoypadState {unsigned previous,repeat,counter;};
static unsigned sampledKeys(unsigned keys,bool opposing){
 if(!opposing){if((keys&0x30)==0x30)keys&=~0x30;if((keys&0xC0)==0xC0)keys&=~0xC0;}return keys;
}
static struct JoypadState probeJoypad(struct mCore *c,unsigned keys,bool opposing,struct JoypadState old,unsigned frame,bool tick,unsigned index){
 struct GB *g=c->board;struct SM83Core *cpu=g->cpu;unsigned sample=sampledKeys(keys,opposing),edge=(old.previous^sample)&sample,masked=sample&0xF3;
 unsigned counter=0,output=edge,marker=1,flags=0x40|(old.repeat==masked?0x80:0)|((old.repeat&15)<(masked&15)?0x20:0)|(old.repeat<masked?0x10:0);
 if(old.repeat==masked){counter=(old.counter+1)&0x9F;if(!counter)counter=0x80;
  if((counter&0x80)&&!(counter&3)){output|=masked;marker=0;flags=0x80;}
  else flags=(counter&0x80)?0x20:0xA0;
 }
 g->allowOpposingDirections=opposing;c->setKeys(c,keys);wr(c,0xFF96,old.previous);wr(c,0xFF99,old.repeat);wr(c,0xFF9A,old.counter);wr(c,0xFF8B,frame);
 wr(c,0xFF95,0x3C);wr(c,0xFF9C,0xA5);wr(c,0xC1B8,0x5A);cpu->a=0x5A;cpu->f.packed=0xF0;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;
 call(c,tick?0x279:0x27C);
 require(cpu->a==marker&&cpu->f.packed==flags&&cpu->bc==((sample&0xF0)<<8|masked)&&cpu->de==0x5678&&cpu->hl==0xFF9A&&
  rd(c,0xFF96)==sample&&rd(c,0xFF97)==edge&&rd(c,0xFF98)==output&&rd(c,0xFF99)==masked&&rd(c,0xFF9A)==counter&&rd(c,0xFF9B)==marker&&
  rd(c,0xFF8B)==((frame+tick)&255)&&rd(c,0xFF95)==0x3C&&rd(c,0xFF9C)==0xA5&&rd(c,0xC1B8)==0x5A&&rd(c,0xFF00)==255,
  "Original joypad sampled keys edge repeat counter AF BC DE HL guards frame wrap",index);
 return (struct JoypadState){sample,masked,counter};
}
/* Independent bounded model of lower-slot straight-line command framing.
   It stops before FE; it does not model loop control or natural IRQ timing. */
struct A1EEvent {unsigned pointer,low,high;};
static int a1eLinearEvents(struct mCore *c,unsigned slot,unsigned start,unsigned end,
                           struct A1EEvent *events,unsigned *count){
 unsigned p=start,n=0;
 while(p<end){
  unsigned op=rd(c,p++);
  if(!((op>=0x80&&op<0xA0)||op==0xB1||op==0xC0||op==0xFD||
       (slot<3&&(op==0xB0||op==0xE0))))return 0;
  if(op>=0x90){if(p>=end)return 0;p++;}
  if(p>=end)return 0;
  unsigned duration=rd(c,p++),low=duration,high=0;
  if(!duration)continue;
  if(duration&0x80){
   if(p>=end)return 0;
   unsigned upper=duration&0x7F;low=rd(c,p++)|((upper&1)?0x80:0);high=upper>>1;
  }
  if(n>=800)return 0;
  events[n++]=(struct A1EEvent){p,low,high};
 }
 *count=n;return p==end&&n;
}
/* Original numeric tile encoding, including low quotient byte and blanks. */
static void a16ExpectedPair(unsigned value,unsigned *out){
 if(value>99){out[0]=0x4E;out[1]=0x47;}
 else{out[0]=value/10?0x20+value/10:0x10;out[1]=0x20+value%10;}
}
static unsigned a16ExpectedField(unsigned value,int word,unsigned *out){
 if(!word){a16ExpectedPair(value,out);out[2]=0;return 3;}
 a16ExpectedPair((value/100)&255,out);a16ExpectedPair(value%100,out+2);
 unsigned seen=0;
 for(unsigned i=0;i<4;i++){
  if(out[i]==0x10){if(seen)out[i]=0x20;}
  else if(out[i]==0x20){if(!seen)out[i]=0x10;}
  else seen=1;
 }
 out[4]=0;return 5;
}
/* Literal 16-round restoring division with an 8-bit remainder register.
   This deliberately retains overflow; it is not host integer division. */
static unsigned modelWordDivision(unsigned value,unsigned divisor){
 unsigned work=value,remainder=0;
 for(unsigned i=0;i<16;i++){
  unsigned carry=work>>15;work=(work<<1)&65535;
  remainder=((remainder<<1)|carry)&255;
  if(remainder>=divisor){remainder=(remainder-divisor)&255;work|=1;}
 }
 return (remainder<<8)|(work&255);
}
static unsigned colorScaled(unsigned value,unsigned mode){
 if(mode==2)return value;
 if(mode<2)return value>>(2-mode);
 return mode-2>=16?0:(value<<(mode-2))&65535;
}
static unsigned a0fRemappedColumn(unsigned column,unsigned row){
 if(row<4)return column;
 if(column==0||column==7)return 11;
 if(column==2||column==10)return 6;
 if(column==5||column==12)return 1;
 return column;
}
static void modelA0FDirections(unsigned held,unsigned *column,unsigned *row,unsigned *variant){
 if(held&0x10){*column=(*column+1)&255;if(*column>=15)*column=0;*column=a0fRemappedColumn(*column,*row);}
 if(held&0x20){*column=(*column-1)&255;if(*column==255)*column=14;*column=a0fRemappedColumn(*column,*row);}
 if(held&0x80){unsigned next=(*row+1)&255;if(next>=4)*column=*column<5?1:*column<10?6:11;*row=next>=5?0:next;*variant=*row<4?0:1;}
 if(held&0x40){*row=(*row-1)&255;if(*row==255){*row=4;*column=*column<5?1:*column<10?6:11;}*variant=*row<4?0:1;}
}
static void probeA12FrameGate(struct mCore *c,unsigned threshold,unsigned counter,unsigned frames,unsigned frame,unsigned loop,unsigned flags,unsigned index){
 struct GB *g=c->board;struct SM83Core *cpu=g->cpu;unsigned nextCounter=counter,nextFrame=frame,nextThreshold=threshold,source=0xD820;
 unsigned expectedA,expectedF,expectedB=0xBE,ret=0;bool copy=false;
 if(!threshold){expectedA=0;expectedF=0xC0;}
 else if(counter<threshold){expectedB=threshold;expectedA=(counter-threshold)&255;expectedF=0x50|((counter&15)<(threshold&15)?0x20:0);}
 else{expectedB=frames;nextCounter=0;unsigned next=(frame+1)&255;
  if(next!=frames){nextFrame=next;expectedA=next;expectedF=0x40|((next&15)<(frames&15)?0x20:0)|(next<frames?0x10:0);copy=true;ret=0x508D;}
  else{nextFrame=0;if(loop){source=0xD900|loop;expectedA=loop;expectedF=0x40;copy=true;ret=0x5086;}else{nextThreshold=0;expectedA=0;expectedF=0x80;}}
 }
 wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 wr(c,0xC5E3,0x33);wr(c,0xC5E4,threshold);wr(c,0xC5E5,counter);wr(c,0xC5E6,frames);wr(c,0xC5E7,frame);wr(c,0xC5E8,loop);wr(c,0xC5E9,0x5A);
 wr(c,0xC5F6,0x3C);wr(c,0xC5F7,0xD8);wr(c,0xC5F8,0x20);wr(c,0xC5FB,0xD9);wr(c,0xC5FC,loop);wr(c,0xC5FD,0xA5);
 wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
 cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x5051;
 unsigned steps=0,target=copy?0x4FFF:0xC100;while(cpu->pc!=target&&steps++<100)c->step(c);
 require(cpu->pc==target&&cpu->sp==(copy?0xCFFC:0xD000)&&(!copy||(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==ret),"A12 frame gate bounded return or actual copy entry with original return",index);
 require(cpu->a==expectedA&&cpu->f.packed==expectedF&&cpu->bc==(expectedB<<8|0xEF)&&cpu->de==0x5678&&cpu->hl==0x9ABC&&rd(c,0xC5E4)==nextThreshold&&rd(c,0xC5E5)==nextCounter&&rd(c,0xC5E6)==frames&&rd(c,0xC5E7)==nextFrame&&rd(c,0xC5E8)==loop&&(rd(c,0xC5F7)<<8|rd(c,0xC5F8))==source&&rd(c,0xC5E3)==0x33&&rd(c,0xC5E9)==0x5A&&rd(c,0xC5F6)==0x3C&&rd(c,0xC5FD)==0xA5,"A12 frame independent threshold wrap completion loop source flags and guards",index);
}
static void probeA12FrameCopy(struct mCore *c,unsigned width,unsigned height,unsigned kind,unsigned plane,unsigned lcd,unsigned entry,unsigned index){
 struct GB *g=c->board;struct SM83Core *cpu=g->cpu;unsigned area=width*height,advance=2*(area&255),source=kind==0?0x4000:kind==1?0x6000:0xD807,selector=kind==0?0x61:kind==1?0x63:0x65,payload[1024];
 wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,selector);wr(c,0x2800,0);wr(c,0x37FF,selector);wr(c,0x3800,0);
 for(unsigned i=0;i<2*area;i++){if(kind==2)wr(c,source+i,(i*37+width*11+height*13)&255);payload[i]=rd(c,source+i);}
 if(kind==2){const unsigned header[]={1,2,width,height,3,1,0};for(unsigned i=0;i<7;i++)wr(c,0xD800+i,header[i]);wr(c,0xD7FF,0x33);wr(c,source+2*area,0x5A);}
 wr(c,0x27FF,0x12);wr(c,0x2800,0);wr(c,0xFFAB,0x12);wr(c,0xFFAC,0);wr(c,0xC113,0x12);wr(c,0xC114,0);
 wr(c,0x37FF,5);wr(c,0x3800,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);wr(c,0xC115,5);wr(c,0xC116,0);
 unsigned aBytes[8],bBytes[8];for(unsigned i=0;i<8;i++){aBytes[i]=rd(c,0x4000+i);bBytes[i]=rd(c,0x6000+i);}
 for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}wr(c,0xFF4F,plane);
 wr(c,0xC21C,selector);wr(c,0xC21D,0);wr(c,0xC5F9,1);wr(c,0xC5FA,2);wr(c,0xC5E2,width);wr(c,0xC5E3,height);wr(c,0xC5E4,1);wr(c,0xC5E5,entry==3?0xA5:1);wr(c,0xC5E6,entry==2?1:3);wr(c,0xC5E7,entry==3?0x5A:0);wr(c,0xC5E8,entry==2);
 unsigned initialSource=entry==2?source+0x200:source;wr(c,0xC5F7,initialSource>>8);wr(c,0xC5F8,initialSource&255);wr(c,0xC5FB,source>>8);wr(c,0xC5FC,source&255);wr(c,0xC5E1,0x33);wr(c,0xC5FD,0x5A);
 cpu->af=0x5AF0;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=entry==3?0xD800:0x9ABC;wr(c,0xFF40,lcd?0x91:0);call(c,entry==3?0x5093:entry?0x5051:0x4FFF);wr(c,0xFF40,0);
 unsigned end=source+advance;bool exact=cpu->af==(entry==3?0x0080:((end&255)<<8|0x80))&&cpu->bc==(width<<8|height)&&cpu->de==source&&cpu->hl==end&&(rd(c,0xC5F7)<<8|rd(c,0xC5F8))==end&&(rd(c,0xC5FB)<<8|rd(c,0xC5FC))==source&&rd(c,0xC5E4)==1&&rd(c,0xC5E5)==(entry?0:1)&&rd(c,0xC5E7)==(entry==1?1:0)&&rd(c,0xC5E1)==0x33&&rd(c,0xC5FD)==0x5A&&(rd(c,0xFF4F)&1)==plane&&g->memory.ime&&rd(c,0xC113)==0x12&&rd(c,0xC114)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0;
 for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==aBytes[i]&&rd(c,0x6000+i)==bBytes[i];
 if(!exact)fprintf(stderr,"Frame copy %u w=%u h=%u kind=%u entry=%u AF=%04X BC=%04X DE=%04X HL=%04X ptr=%02X%02X count=%u frame=%u\n",index,width,height,kind,entry,cpu->af,cpu->bc,cpu->de,cpu->hl,rd(c,0xC5F7),rd(c,0xC5F8),rd(c,0xC5E5),rd(c,0xC5E7));
 require(exact,"A12 full direct tick loop setup copy source low-product advance registers mapper guards",index);
 exact=true;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){bool tile=i>=0x1841&&i<0x1841+height*32&&((i-0x1841)%32)<width;unsigned expected=tile?payload[bank*area+((i-0x1841)/32)*width+(i-0x1841)%32]:0xA5;exact&=rd(c,0x8000+i)==expected;}}
 if(kind==2){exact&=rd(c,0xD7FF)==0x33&&rd(c,source+2*area)==0x5A;for(unsigned i=0;i<2*area;i++)exact&=rd(c,source+i)==payload[i];}
 require(exact,"A12 exact original two-plane tilemap complete VRAM source footprint and payload guards",index);
}
static unsigned a12NextState(unsigned state){return (17*state+0x5C93)&65535;}
static unsigned a12StepFlags(unsigned state){unsigned product=(17*state)&65535,carry=((product&255)+0x93)>255,sum=(product>>8)+0x5C+carry;return (!(sum&255)?0x80:0)|(((product>>8)&15)+12+carry>15?0x20:0)|(sum>255?0x10:0);}
static void probeA12Random(struct mCore *c,unsigned state,unsigned a,unsigned flags,bool seed,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;wr(c,0xC5D1,0x33);wr(c,0xC5D2,state&255);wr(c,0xC5D3,state>>8);wr(c,0xC5D4,0x5A);
 cpu->a=a;cpu->f.packed=flags;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=seed?state:0x9ABC;call(c,seed?0x4BDD:0x4BE6);
 unsigned next=seed?state:a12NextState(state);
 require((rd(c,0xC5D2)|(rd(c,0xC5D3)<<8))==next&&rd(c,0xC5D1)==0x33&&rd(c,0xC5D4)==0x5A&&cpu->bc==0xBEEF&&cpu->a==(seed?(state>>8):(next>>8))&&cpu->f.packed==(seed?flags:a12StepFlags(state))&&cpu->hl==(seed?state:(17*state)&65535)&&cpu->de==(seed?0x5678:((next&255)<<8|next>>8)),"A12 seed or recurrence independent 16-bit arithmetic ADC flags register guards",index);
}
static unsigned a12TriggerChoice(unsigned seed,unsigned *state,unsigned *previous){
 unsigned first=a12NextState(seed);*previous=seed;*state=first;if(!(first>>8))return 1;
 *previous=first;*state=a12NextState(first);return ((*state>>8)&15)?0:2;
}
static void probeA12TriggerPrefix(struct mCore *c,unsigned seed,unsigned flags,unsigned index){
 struct GB *g=c->board;struct SM83Core *cpu=g->cpu;unsigned state,previous,choice=a12TriggerChoice(seed,&state,&previous);
 wr(c,0xC5A4,6);wr(c,0xC5CF,1);wr(c,0xC5E4,0);wr(c,0xC5E5,0xA5);wr(c,0xC5E7,0x5A);wr(c,0xC5D1,0x33);wr(c,0xC5D2,seed&255);wr(c,0xC5D3,seed>>8);wr(c,0xC5D4,0x3C);
 wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4C11;
 unsigned target=choice?0x5093:0xC100,steps=0;while(cpu->pc!=target&&steps++<300)c->step(c);
 unsigned expectedHL=choice?(choice==1?0x6A96:0x6AB1):(17*previous)&65535;
 require(cpu->pc==target&&cpu->sp==(choice?0xCFFC:0xD000)&&(!choice||(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==(choice==1?0x4C31:0x4C40)),"A12 guarded consumer original RNG chain returns or reaches actual setup prefix",index);
 require(cpu->bc==0xBEEF&&cpu->de==((state&255)<<8|state>>8)&&cpu->hl==expectedHL&&cpu->a==(choice?0:(state>>8)&15)&&cpu->f.packed==(choice?0xA0:0x20)&&(rd(c,0xC5D2)|(rd(c,0xC5D3)<<8))==state&&rd(c,0xC5D1)==0x33&&rd(c,0xC5D4)==0x3C&&rd(c,0xC5E4)==0&&rd(c,0xC5E5)==0xA5&&rd(c,0xC5E7)==0x5A,"A12 consumer all seed paths recurrence steps target registers flags and guards",index);
}
/* Independent twenty-step recurrence and pair substitution oracle. LCD off. */
static void probeA12TileCycle(struct mCore *c,unsigned seed,unsigned tile,unsigned plane,bool whole,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;unsigned state=seed,expectedA=0,expectedDE=0,carry=0;
 unsigned upper[20],lower[20];
 wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 if(whole)for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0x3C);}
 wr(c,0xFF4F,plane);
 for(unsigned i=0;i<20;i++){upper[i]=(tile+i)%256;lower[i]=(0x51+i)%256;wr(c,0x9920+i,upper[i]);wr(c,0x9940+i,lower[i]);}
 wr(c,0xC5D1,0xA5);wr(c,0xC5D2,seed&255);wr(c,0xC5D3,seed>>8);wr(c,0xC5D4,0x5A);
 for(unsigned i=0;i<20;i++){
  state=a12NextState(state);expectedDE=(state&255)<<8|state>>8;expectedA=(state>>8)&127;carry=0;
  if(!expectedA){expectedDE=32;expectedA=upper[i];carry=upper[i]<0xA7;
   if(upper[i]>=0xA5&&upper[i]<=0xA7){upper[i]=upper[i]==0xA7?0xA5:upper[i]+1;lower[i]=upper[i]+3;expectedA=lower[i];carry=0;}
  }
 }
 cpu->af=0x5A00|((index&15)<<4);cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x4C41);
 require(cpu->a==expectedA&&cpu->f.packed==(0xC0|carry<<4)&&cpu->bc==0x0037&&cpu->de==expectedDE&&cpu->hl==0x9934,
  "A12 paired cycle exact terminal registers flags twenty columns",index);
 require((rd(c,0xC5D2)|(rd(c,0xC5D3)<<8))==state&&rd(c,0xC5D1)==0xA5&&rd(c,0xC5D4)==0x5A&&(rd(c,0xFF4F)&1)==plane,
  "A12 paired cycle twenty RNG steps WRAM guards and unchanged VBK",index);
 bool exact=true;for(unsigned i=0;i<20;i++)exact&=rd(c,0x9920+i)==upper[i]&&rd(c,0x9940+i)==lower[i];
 require(exact,"A12 paired cycle recognized substitutions and unrecognized bytes unchanged",index);
 if(whole){exact=true;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){
  unsigned address=0x8000+i,expected=0x3C;
  if(bank==plane&&address>=0x9920&&address<0x9934)expected=upper[address-0x9920];
  if(bank==plane&&address>=0x9940&&address<0x9954)expected=lower[address-0x9940];
  exact&=rd(c,address)==expected;
 }}require(exact,"A12 paired cycle both entire VRAM planes exact bounded footprint",index);wr(c,0xFF4F,plane);}
}
/* Prepared upper-stream program: all selectors use the same one-channel record. */
static void prepareA12EffectAudio(struct mCore *c){
 wr(c,0xC663,0x14);wr(c,0xC664,0);wr(c,0xCF92,0);wr(c,0xCF93,0xDB);wr(c,0xCF89,0);
 for(unsigned i=0;i<128;i++){wr(c,0xDB00+2*i,0x10);wr(c,0xDB01+2*i,0xDC);}
 wr(c,0xDC10,1);wr(c,0xDC11,0);wr(c,0xDC15,0);wr(c,0xDC16,0xDD);wr(c,0xDD00,7);
 for(unsigned i=0;i<128;i++)wr(c,0xCF00+i,0x5A);
}
static void prepareA12EffectMapping(struct mCore *c,unsigned requested){
 wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);wr(c,0xFFAB,0x12);wr(c,0xFFAC,0);wr(c,0xC113,0x12);wr(c,0xC114,0);
 wr(c,0x37FF,5);wr(c,0x3800,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);wr(c,0xC115,5);wr(c,0xC116,0);wr(c,0xFF9D,0x37);wr(c,0xFF9E,0x39);wr(c,0xC21C,requested);wr(c,0xC21D,0);
}
static void probeA12TileEffect(struct mCore *c,unsigned width,unsigned height,unsigned frame,unsigned flags,unsigned plane,unsigned lcd,bool whole,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;prepareA12EffectMapping(c,0x65);
 unsigned area=width*height,advance=2*(area&255),header[]={1,2,width,height,3,7,1};
 for(unsigned i=0;i<7;i++)wr(c,0xD800+i,header[i]);for(unsigned i=0;i<2*area;i++)wr(c,0xD807+i,(i*37+width+height)&255);wr(c,0xD807+2*area,0x33);
 const unsigned marker[]={255,0x5A,0,0xD8};for(unsigned i=0;i<4;i++)wr(c,0xD100+i,marker[i]);wr(c,0xD0FF,0x37);wr(c,0xD104,0x39);
 for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);if(whole){for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}else{wr(c,0x9840,0xA5);wr(c,0x9841,0xA5);wr(c,0x9842,0xA5);}}
 wr(c,0xFF4F,plane);wr(c,0xC5CE,frame);wr(c,0xC5E5,0xA5);wr(c,0xC5E7,0x5A);wr(c,0xC5E1,0x37);wr(c,0xC5FD,0x39);cpu->af=0x5A00|flags;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0xD100;if(lcd)wr(c,0xFF40,0x91);call(c,0x4FAF);
 unsigned end=0xD807+advance;bool exact=cpu->af==0x0080&&cpu->bc==(width<<8|height)&&cpu->de==0xD807&&cpu->hl==0xD104&&rd(c,0xC5CE)==((frame+1)&255)&&rd(c,0xC5E5)==0&&rd(c,0xC5E7)==0&&rd(c,0xC5F9)==1&&rd(c,0xC5FA)==2&&rd(c,0xC5E2)==width&&rd(c,0xC5E3)==height&&rd(c,0xC5E6)==3&&rd(c,0xC5E4)==7&&rd(c,0xC5E8)==1&&(rd(c,0xC5F7)<<8|rd(c,0xC5F8))==end&&(rd(c,0xC5FB)<<8|rd(c,0xC5FC))==0xD807&&rd(c,0xC5E1)==0x37&&rd(c,0xC5FD)==0x39&&rd(c,0xD0FF)==0x37&&rd(c,0xD104)==0x39&&rd(c,0xFFAD)==5&&rd(c,0xC115)==5&&rd(c,0xFF9D)==width&&rd(c,0xFF9E)==0x39&&(rd(c,0xFF4F)&1)==plane;
 require(exact,"A12 FF complete original copy register header low-product pointer index reset guards and mapper",index);
 wr(c,0xFF40,0);exact=true;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);if(whole){for(unsigned i=0;i<8192;i++){bool tile=i>=0x1841&&i<0x1841+height*32&&((i-0x1841)%32)<width;unsigned expected=tile?((bank*area+((i-0x1841)/32)*width+(i-0x1841)%32)*37+width+height)&255:0xA5;exact&=rd(c,0x8000+i)==expected;}}else{exact&=rd(c,0x9840)==0xA5&&rd(c,0x9841)==((bank*area*37+width+height)&255)&&rd(c,0x9842)==0xA5;}}
 for(unsigned i=0;i<2*area;i++)exact&=rd(c,0xD807+i)==((i*37+width+height)&255);exact&=rd(c,0xD807+2*area)==0x33;require(exact,"A12 FF exact two-plane payload or full VRAM and immutable synthetic source guard",index);
}
static void probeA12ResourceCommand(struct mCore *c,unsigned command,unsigned variant,unsigned state,unsigned flags,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;
 bool transition=(command>=0xF1&&command<=0xF7)||command==0xFE,countdown=command>=0xF4&&command<=0xF6;
 unsigned colors[64],last=0;for(unsigned i=0;i<64;i++)colors[i]=rd(c,0x53B2+128*variant+2*i)|(rd(c,0x53B3+128*variant+2*i)<<8);
 wr(c,0xC5FD,command);wr(c,0xC5A8,variant);wr(c,0xC5A3,state);wr(c,0xC214,0x37);wr(c,0xC624,0x39);wr(c,0xC706,0x3C);wr(c,0xC213,0x5A);wr(c,0xC1C4,0x3C);wr(c,0xC738,0x39);wr(c,0xC21F,0x37);wr(c,0xC220,0x39);wr(c,0xC221,0x3C);wr(c,0xC2A2,0x5A);wr(c,0xC422,0x3C);
 const unsigned fields[]={0xCF86,0xCF87,0xC665,0xC666,0xC667,0xC66B};for(unsigned i=0;i<6;i++)wr(c,fields[i],0x37);
 cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x4AC9);
 unsigned next=(state+1)&255,a=transition?next:command==0xF0?1:command,f=transition?((next?0:0x80)|((state&15)==15?0x20:0)):command==0||command==0xF0?0xC0:0x40|((command&15)<14?0x20:0)|(command<254?0x10:0);
 bool exact=cpu->af==(a<<8|f)&&cpu->bc==(transition?0:0xBEEF)&&cpu->hl==(transition?0x8F4:0x5678)&&rd(c,0xC5FD)==command&&rd(c,0xC5A8)==variant&&rd(c,0xC5A3)==(transition?next:state)&&rd(c,0xC738)==(command==0xF0?1:0x39)&&rd(c,0xC213)==(transition?0:0x5A)&&rd(c,0xC1C4)==(transition?0:0x3C)&&rd(c,0xC624)==(command==0xF1?0:0x39)&&rd(c,0xC706)==(countdown?(command==0xF4?1:command==0xF5?2:0):0x3C)&&rd(c,0xC214)==(transition?(command==0xF1?0:command==0xF2?1:command==0xF3?2:command==0xF7?6:4):0x37)&&rd(c,0xC21F)==0x37&&rd(c,0xC221)==0x3C;
 for(unsigned i=0;i<6;i++)exact&=rd(c,fields[i])==(countdown?(i==0?2:i==1?1:0):0x37);
 if(transition){for(unsigned i=0;i<192;i++){unsigned component=(colors[i/3]>>(5*(i%3)))&31,base=component*2048,delta=(31-component)*256;last=delta;exact&=rd(c,0xC2A2+2*i)==(base&255)&&rd(c,0xC2A3+2*i)==base>>8&&rd(c,0xC422+2*i)==(delta&255)&&rd(c,0xC423+2*i)==delta>>8;}exact&=rd(c,0xC220)==8&&rd(c,0xC5A2)==2;}else exact&=rd(c,0xC220)==0x39&&rd(c,0xC2A2)==0x5A&&rd(c,0xC422)==0x3C;
 exact&=cpu->de==(transition?last:0x1234);
 require(exact,"A12 full resource commands real countdown palettes state fields registers flags no command clear",index);
}
static unsigned a12ActionEntry(unsigned v,unsigned a){const unsigned e[3][6]={{0x4786,0x47D2,0x47F0,0x47A4,0x481E,0x483C},{0x487C,0x48B8,0x48D6,0x489A,0x4904,0x4922},{0x4962,0x49AE,0x49CC,0x4980,0x49FA,0x4A18}};return e[v][a];}
static unsigned a12ActionHeader(unsigned v,unsigned a,unsigned value){
 const unsigned h[3][6]={{0x6895,0x6895,0x68EF,0x69AC,0x6B74,0x6B9E},{0x6866,0x6866,0x689D,0x68CB,0x6A7F,0x6A51},{0x6800,0x6800,0x6837,0x6855,0x6ACE,0x6AA8}};
 if(v==0&&a==2&&value>=3)return 0x6939;if(v==0&&a==3&&value>=6)return 0x69CB;if(v==1&&a==2&&value>=6)return 0x68B4;if(v==2&&a==2&&value>=2)return 0x6846;if(v==2&&a==3&&value>=3)return 0x6874;return h[v][a];
}
static void probeA12InputAction(struct mCore *c,unsigned v,unsigned action,unsigned value,unsigned flags,unsigned plane,unsigned lcd,bool whole,bool nested,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;const unsigned selectors[]={0x61,0x63,0x65},tables[]={0x6BBD,0x6AD0,0x6AE5},phases[3][6]={{7,8,3,5,4,6},{7,8,3,5,4,6},{7,8,3,5,6,4}};
 unsigned sel=selectors[v],phase=phases[v][action],header=a12ActionHeader(v,action,value);
 prepareA12EffectMapping(c,sel);prepareA12EffectAudio(c);wr(c,0x37FF,sel);wr(c,0xFFAD,sel);wr(c,0xC115,sel);
 unsigned h[7];for(unsigned i=0;i<7;i++)h[i]=rd(c,header+i);unsigned area=h[2]*h[3],end=header+7+2*(area&255),origin=0x9800+h[1]*32+h[0];
 require(area>0&&area<=255&&h[0]+h[2]<=32&&origin+h[3]*32<=0xA000,"A12 original action header measured bounded geometry",index);
 unsigned payload[510];for(unsigned i=0;i<2*area;i++)payload[i]=rd(c,header+7+i);
 unsigned ptr=rd(c,tables[v]+phase*2)|(rd(c,tables[v]+phase*2+1)<<8),count=rd(c,ptr),p=ptr+1,record[4];for(unsigned i=0;i<4;i++)record[i]=rd(c,p+i);
 require(record[0]!=255&&record[0]!=254,"A12 action original reset first record ordinary no fake effect skip",index);
 unsigned q=p+4;if(rd(c,q)==255)q+=4;if(rd(c,q)==254)q+=4;unsigned next[4];for(unsigned i=0;i<4;i++)next[i]=rd(c,q+i);
 if(whole)for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
 wr(c,0xFF70,7);for(unsigned i=0;i<320;i++)wr(c,0xD000+i,(i*13+v*17+action)&255);wr(c,0xD140,0x37);wr(c,0xFF70,2);wr(c,0xFF4F,plane);
 wr(c,0xC5A8,v);wr(c,0xC5A4,value);wr(c,0xC214,action);wr(c,0xC732,0x37);wr(c,0xC601,0x39);wr(c,0xC5A3,0x3C);wr(c,0xC600,1);wr(c,0xC213,0x5A);wr(c,0xC5CF,1);wr(c,0xC5CC,0x5A);wr(c,0xC5CE,0x39);wr(c,0xC5E5,0x3C);wr(c,0xC5E7,0x37);wr(c,0xC5E1,0x39);cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;
 if(nested)wr(c,0xFF97,3);if(lcd)wr(c,0xFF40,0xF1);callWithLimit(c,nested?0x470F:a12ActionEntry(v,action),2000000);
 unsigned x=(record[1]-0xC9)&255,y=(record[2]-0xD0)&255,nx=(next[1]-0xC9)&255,ny=(next[2]-0xD0)&255,lo=y<ny?y:ny,hi=y>ny?y:ny,dy=hi-lo,f=0x40|(!dy?0x80:0)|((hi&15)<(lo&15)?0x20:0);
 bool exact=cpu->af==(dy<<8|f)&&cpu->bc==(lo<<8|h[3])&&cpu->de==p&&cpu->hl==q+4&&rd(c,0xC213)==0&&rd(c,0xC600)==2&&rd(c,0xC5CF)==phase&&rd(c,0xC5CC)==0&&rd(c,0xC5CE)==0&&rd(c,0xC5A8)==v&&rd(c,0xC5A4)==value&&rd(c,0xC214)==action&&rd(c,0xC732)==(nested?action:0x37)&&rd(c,0xC601)==0x39&&rd(c,0xC5A3)==0x3C&&rd(c,0xC5CD)==count&&rd(c,0xC5D0)==record[0]&&rd(c,0xC5D7)==x&&rd(c,0xC5D8)==y&&rd(c,0xC5CB)==record[3]&&rd(c,0xC5D1)==next[0]&&rd(c,0xC5D9)==nx&&rd(c,0xC5DA)==ny&&rd(c,0xC5FD)==next[3]&&rd(c,0xC5DD)==(x>nx?x-nx:nx-x)&&rd(c,0xC5DE)==dy&&rd(c,0xC5E5)==0&&rd(c,0xC5E7)==0&&rd(c,0xC5E1)==0x39&&(rd(c,0xC5F7)<<8|rd(c,0xC5F8))==end&&(rd(c,0xC5FB)<<8|rd(c,0xC5FC))==header+7&&rd(c,0xC5F9)==h[0]&&rd(c,0xC5FA)==h[1]&&rd(c,0xC5E2)==h[2]&&rd(c,0xC5E3)==h[3]&&rd(c,0xC5E6)==h[4]&&rd(c,0xC5E4)==h[5]&&rd(c,0xC5E8)==h[6]&&rd(c,0xFF40)==(lcd?0x91:0)&&(rd(c,0xFF4F)&1)==0&&rd(c,0xFFAD)==sel&&rd(c,0xC115)==sel&&rd(c,0xFFAB)==0x12&&rd(c,0xC113)==0x12&&(rd(c,0xFF70)&7)==2;
 if(nested)exact&=rd(c,0xFF97)==0&&rd(c,0xCF82)==0&&rd(c,0xCF89)==0x11;
 require(exact,"A12 complete original action hide header copy reset mapped resource coordinates registers fields guards",index);
 if(whole){wr(c,0xFF40,0);exact=true;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){unsigned address=0x8000+i,row=i>=0x1C00?(i-0x1C00)/32:256,col=i%32,expected=row<8&&col<20?((bank*160+row*20+col)*13+v*17+action)&255:0xA5;if(address>=origin){unsigned j=address-origin,y0=j/32,x0=j%32;if(y0<h[3]&&x0<h[2])expected=payload[bank*area+y0*h[2]+x0];}exact&=rd(c,address)==expected;}}
  wr(c,0xFF70,7);for(unsigned i=0;i<320;i++)exact&=rd(c,0xD000+i)==((i*13+v*17+action)&255);exact&=rd(c,0xD140)==0x37;wr(c,0xFF70,2);require(exact,"A12 complete action composition both full VRAM planes unchanged synthetic source guard",index);
 }
}
static void probeA12OAMEmission(struct mCore *c,unsigned family,unsigned available,unsigned count,unsigned index,unsigned x,unsigned y,unsigned flags,unsigned caseIndex){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;prepareA12EffectMapping(c,0x63);
 unsigned expected[1024];for(unsigned i=0;i<1024;i++)wr(c,0xC000+i,0xA5);wr(c,0xC21C,0x63);wr(c,0xC21D,0);wr(c,0xC115,5);wr(c,0xC116,0);wr(c,0xC113,0x12);wr(c,0xC114,0);
 for(unsigned i=0;i<128;i++){wr(c,0xD000+2*i,0);wr(c,0xD001+2*i,0xD2);}wr(c,0xD200,count);
 unsigned records=count?count:256;for(unsigned i=0;i<records;i++){wr(c,0xD201+4*i,(i*17+index)&255);wr(c,0xD202+4*i,(i*29+count)&255);wr(c,0xD203+4*i,(i*37+available)&255);wr(c,0xD204+4*i,(i*43+family)&255);}
 wr(c,0xC1C7,available);wr(c,0xC5F5,available);wr(c,family?0xC5F6:0xC5D0,index);wr(c,family?0xC5E9:0xC5D5,x);wr(c,family?0xC5EA:0xC5D6,y);
 for(unsigned i=0;i<1024;i++)expected[i]=rd(c,0xC000+i);
 unsigned dest=0xC000+4*((40-available)&255),base=dest&0xFF00,e=dest&255,lastAttr=0,lastX=0,carry=0;
 if(available)for(unsigned i=0;i<records;i++){unsigned ox=(i*29+count)&255,oy=(i*17+index)&255,tile=(i*37+available)&255,attr=(i*43+family)&255;unsigned vals[]={ (y+oy+16)&255,(x+ox+8)&255,tile,attr};for(unsigned j=0;j<4;j++){expected[base-0xC000+e]=vals[j];e=(e+1)&255;}lastAttr=attr;lastX=ox;carry=(((x+ox)&255)+8)>255;}
 cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0xD000;call(c,family?0x5188:0x4DFE);
 bool exact=true;for(unsigned i=0;i<1024;i++)exact&=rd(c,0xC000+i)==expected[i];
 exact&=cpu->af==(available?(lastAttr<<8|0xC0|(carry?0x10:0)):0x0080)&&cpu->bc==(available?lastX:0xBEEF)&&cpu->de==(available?(base|e):0x1234)&&cpu->hl==(available?0xD201+4*records:0xD000)&&rd(c,0xC5F5)==(family?available:available?(available-records)&255:0)&&rd(c,0xFFAD)==0x63&&rd(c,0xFFAE)==0&&rd(c,0xFF9D)==5&&rd(c,0xFF9E)==0&&rd(c,0xC115)==expected[0x115]&&rd(c,0xC116)==expected[0x116]&&rd(c,family?0xC5F6:0xC5D0)==index&&rd(c,family?0xC5E9:0xC5D5)==x&&rd(c,family?0xC5EA:0xC5D6)==y;
 for(unsigned i=0;i<records;i++)exact&=rd(c,0xD201+4*i)==((i*17+index)&255)&&rd(c,0xD202+4*i)==((i*29+count)&255)&&rd(c,0xD203+4*i)==((i*37+available)&255)&&rd(c,0xD204+4*i)==((i*43+family)&255);
 require(exact,"A12 OAM original emitters counts index coordinate wrapping whole C000-C3FF mapper mirror and source",caseIndex);
}
struct A12StepModel {unsigned q,r;};
static struct A12StepModel a12StepModel(unsigned distance,unsigned divisor,unsigned counter){
 struct A12StepModel m={0,0};for(unsigned i=0;i<(counter?counter:256);i++){unsigned value=(distance+m.r)&255;m.q=divisor?value/divisor:255;m.r=divisor?value%divisor:value;}return m;
}
static void probeA12StepCalculation(struct mCore *c,unsigned dx,unsigned dy,unsigned divisor,unsigned counter,unsigned flags,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;struct A12StepModel x=a12StepModel(dx,divisor,counter),y=a12StepModel(dy,divisor,counter);
 wr(c,0xC5DD,dx);wr(c,0xC5DE,dy);wr(c,0xC5CB,divisor);wr(c,0xC5CC,counter);for(unsigned i=0;i<6;i++)wr(c,0xC5DB+i,0x5A);wr(c,0xC5DD,dx);wr(c,0xC5DE,dy);wr(c,0xC5DA,0x37);wr(c,0xC5E1,0x39);
 cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;callWithLimit(c,0x4F6A,200000);
 require(cpu->af==(y.r<<8|0xC0|((y.q&1)?0:0x10))&&cpu->bc==divisor&&cpu->de==0x1234&&cpu->hl==(y.q<<8|y.r)&&rd(c,0xC5DB)==x.q&&rd(c,0xC5DC)==y.q&&rd(c,0xC5DF)==x.r&&rd(c,0xC5E0)==y.r&&rd(c,0xC5DD)==dx&&rd(c,0xC5DE)==dy&&rd(c,0xC5CB)==divisor&&rd(c,0xC5CC)==counter&&rd(c,0xC5DA)==0x37&&rd(c,0xC5E1)==0x39,"A12 whole step recurrence independent wrapped quotient remainder all output register guard fields",index);
}
static void probeA12Movement(struct mCore *c,unsigned x,unsigned y,unsigned tx,unsigned ty,unsigned divisor,unsigned counter,unsigned flags,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;unsigned dx=x>tx?x-tx:tx-x,dy=y>ty?y-ty:ty-y;bool same=x==tx&&y==ty;struct A12StepModel sx=a12StepModel(dx,divisor,counter),sy=a12StepModel(dy,divisor,counter);
 unsigned nx=x==tx?x:(x<tx?x+sx.q:x-sx.q)&255,ny=y==ty?y:(y<ty?y+sy.q:y-sy.q)&255,a,f,b;
 if(same){a=0;f=0x80;b=y;}else if(y==ty){a=ty;f=0xC0;b=y;}else if(y<ty){a=ny;f=(ny?0:0x80)|((y&15)+(sy.q&15)>15?0x20:0)|(y+sy.q>255?0x10:0);b=sy.q;}else{a=ny;f=0x40|(ny?0:0x80)|((y&15)<(sy.q&15)?0x20:0)|(y<sy.q?0x10:0);b=sy.q;}
 wr(c,0xC5D7,x);wr(c,0xC5D8,y);wr(c,0xC5D9,tx);wr(c,0xC5DA,ty);wr(c,0xC5DD,dx);wr(c,0xC5DE,dy);wr(c,0xC5CB,divisor);wr(c,0xC5CC,counter);wr(c,0xC5DB,0x37);wr(c,0xC5DC,0x39);wr(c,0xC5DF,0x3C);wr(c,0xC5E0,0x5A);wr(c,0xC5D6,0x37);wr(c,0xC5E1,0x39);
 cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;callWithLimit(c,0x4EEA,200000);
 require(cpu->af==(a<<8|f)&&cpu->bc==(b<<8|(same?0:divisor))&&cpu->de==0x1234&&cpu->hl==(same?0x5678:sy.q<<8|sy.r)&&rd(c,0xC5D7)==nx&&rd(c,0xC5D8)==ny&&rd(c,0xC5D9)==tx&&rd(c,0xC5DA)==ty&&rd(c,0xC5DB)==(same?0x37:sx.q)&&rd(c,0xC5DC)==(same?0x39:sy.q)&&rd(c,0xC5DF)==(same?0x3C:sx.r)&&rd(c,0xC5E0)==(same?0x5A:sy.r)&&rd(c,0xC5CB)==divisor&&rd(c,0xC5CC)==counter&&rd(c,0xC5DD)==dx&&rd(c,0xC5DE)==dy&&rd(c,0xC5D6)==0x37&&rd(c,0xC5E1)==0x39,"A12 whole movement independent unsigned directions byte overflow equality and complete register fields",index);
}
static void probeA12SecondaryStepCalculation(struct mCore *c,unsigned dx,unsigned dy,unsigned divisor,unsigned counter,unsigned flags,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;struct A12StepModel x=a12StepModel(dx,divisor,counter),y=a12StepModel(dy,divisor,counter);
 wr(c,0xC5F1,dx);wr(c,0xC5F2,dy);wr(c,0xC5CB,divisor);wr(c,0xC5CC,counter);for(unsigned i=0;i<6;i++)wr(c,0xC5EF+i,0x5A);wr(c,0xC5F1,dx);wr(c,0xC5F2,dy);wr(c,0xC5EE,0x37);wr(c,0xC5F5,0x39);
 cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;callWithLimit(c,0x52CF,200000);
 require(cpu->af==(y.r<<8|0xC0|((y.q&1)?0:0x10))&&cpu->bc==divisor&&cpu->de==0x1234&&cpu->hl==(y.q<<8|y.r)&&rd(c,0xC5EF)==x.q&&rd(c,0xC5F0)==y.q&&rd(c,0xC5F3)==x.r&&rd(c,0xC5F4)==y.r&&rd(c,0xC5F1)==dx&&rd(c,0xC5F2)==dy&&rd(c,0xC5CB)==divisor&&rd(c,0xC5CC)==counter&&rd(c,0xC5EE)==0x37&&rd(c,0xC5F5)==0x39,"A12 secondary whole step recurrence independent wrapped quotient remainder all output register guard fields",index);
}
static void probeA12SecondaryMovement(struct mCore *c,unsigned x,unsigned y,unsigned tx,unsigned ty,unsigned divisor,unsigned counter,unsigned flags,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;unsigned dx=x>tx?x-tx:tx-x,dy=y>ty?y-ty:ty-y;bool same=x==tx&&y==ty;struct A12StepModel sx=a12StepModel(dx,divisor,counter),sy=a12StepModel(dy,divisor,counter);
 unsigned nx=x==tx?x:(x<tx?x+sx.q:x-sx.q)&255,ny=y==ty?y:(y<ty?y+sy.q:y-sy.q)&255,a,f,b;
 if(same){a=0;f=0x80;b=y;}else if(y==ty){a=ty;f=0xC0;b=y;}else if(y<ty){a=ny;f=(ny?0:0x80)|((y&15)+(sy.q&15)>15?0x20:0)|(y+sy.q>255?0x10:0);b=sy.q;}else{a=ny;f=0x40|(ny?0:0x80)|((y&15)<(sy.q&15)?0x20:0)|(y<sy.q?0x10:0);b=sy.q;}
 wr(c,0xC5EB,x);wr(c,0xC5EC,y);wr(c,0xC5ED,tx);wr(c,0xC5EE,ty);wr(c,0xC5F1,dx);wr(c,0xC5F2,dy);wr(c,0xC5CB,divisor);wr(c,0xC5CC,counter);wr(c,0xC5EF,0x37);wr(c,0xC5F0,0x39);wr(c,0xC5F3,0x3C);wr(c,0xC5F4,0x5A);wr(c,0xC5EA,0x37);wr(c,0xC5F5,0x39);
 cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;callWithLimit(c,0x526A,200000);
 require(cpu->af==(a<<8|f)&&cpu->bc==(b<<8|(same?0:divisor))&&cpu->de==0x1234&&cpu->hl==(same?0x5678:sy.q<<8|sy.r)&&rd(c,0xC5EB)==nx&&rd(c,0xC5EC)==ny&&rd(c,0xC5ED)==tx&&rd(c,0xC5EE)==ty&&rd(c,0xC5EF)==(same?0x37:sx.q)&&rd(c,0xC5F0)==(same?0x39:sy.q)&&rd(c,0xC5F3)==(same?0x3C:sx.r)&&rd(c,0xC5F4)==(same?0x5A:sy.r)&&rd(c,0xC5CB)==divisor&&rd(c,0xC5CC)==counter&&rd(c,0xC5F1)==dx&&rd(c,0xC5F2)==dy&&rd(c,0xC5EA)==0x37&&rd(c,0xC5F5)==0x39,"A12 secondary whole movement independent unsigned directions byte overflow equality and complete register fields",index);
}
static uint8_t originalSecondaryResources[803];
static unsigned originalSecondaryCrossings;
struct OriginalA12Secondary {unsigned x,y,tx,ty,index,dx,dy,lo,f,base,end;};
static struct OriginalA12Secondary originalA12SecondaryModel(struct mCore *c,unsigned phase,unsigned frame){
 const uint8_t *rom=((struct GB*)c->board)->memory.rom;const unsigned pointers[]={0x6EF2,0x6F57,0x7080,0x70BD,0x70FE,0x713B,0x716C,0x71A1,0x71D2};
 unsigned base=pointers[phase],p=base+1+4*frame,objectEnd=base+1+4*(rom[0x61*8192+base-0x6000]+1);struct OriginalA12Secondary m={0};
 #define SECONDARY_BYTE(a) rom[0x61*8192+(a)-0x6000]
 if(SECONDARY_BYTE(p)==255)p+=4;if(SECONDARY_BYTE(p)==254)p+=4;
 m.index=SECONDARY_BYTE(p);m.x=(SECONDARY_BYTE(p+1)-201)&255;m.y=(SECONDARY_BYTE(p+2)-208)&255;p+=4;
 if(SECONDARY_BYTE(p)==255)p+=4;if(SECONDARY_BYTE(p)==254)p+=4;
 m.tx=(SECONDARY_BYTE(p+1)-201)&255;m.ty=(SECONDARY_BYTE(p+2)-208)&255;m.end=p+3;m.base=base+1;
 if(m.end>=0x8000||base<0x6000){fprintf(stderr,"Original secondary model leaves measured ROM window\n");exit(12);}
 originalSecondaryCrossings+=m.end>objectEnd;
 m.dx=m.x>m.tx?m.x-m.tx:m.tx-m.x;m.dy=m.y>m.ty?m.y-m.ty:m.ty-m.y;m.lo=m.y<m.ty?m.y:m.ty;unsigned hi=m.y>m.ty?m.y:m.ty;
 m.f=0x40|(m.dy?0:0x80)|((hi&15)<(m.lo&15)?0x20:0);
 #undef SECONDARY_BYTE
 return m;
}
static void probeOriginalA12Secondary(struct mCore *c,unsigned phase,unsigned frame,unsigned count,unsigned flags,bool tick,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;bool wrap=((frame+1)&255)==count;unsigned readFrame=tick?(wrap?0:(frame+1)&255):frame;struct OriginalA12Secondary m=originalA12SecondaryModel(c,phase,readFrame);
 prepareA12EffectMapping(c,0x61);wr(c,0xC5CF,phase);wr(c,0xC5CE,frame);wr(c,0xC5CD,count);wr(c,0xC5CB,7);wr(c,0xC5CC,7);wr(c,0xC5EA,0x37);wr(c,0xC5EF,0x39);wr(c,0xC5F0,0x3C);wr(c,0xC5F3,0x5A);wr(c,0xC5F4,0xA5);wr(c,0xC5F5,0x37);wr(c,0xC5F7,0x39);wr(c,0xC5D7,0x3C);wr(c,0xC5D8,0x5A);
 cpu->af=0x5A00|flags;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x5678;call(c,tick?0x50DF:0x50D8);
 unsigned af=tick?(frame<<8|0x40|(frame?0:0x80)|((frame&15)==15?0x20:0)):(m.dy<<8|m.f);
 require(cpu->af==af&&cpu->bc==(m.lo<<8|0x37)&&cpu->de==m.base&&cpu->hl==m.end&&rd(c,0xC5CE)==frame&&rd(c,0xC5CF)==phase&&rd(c,0xC5EB)==m.x&&rd(c,0xC5EC)==m.y&&rd(c,0xC5ED)==m.tx&&rd(c,0xC5EE)==m.ty&&rd(c,0xC5F1)==m.dx&&rd(c,0xC5F2)==m.dy&&rd(c,0xC5F6)==m.index,"A12 original secondary whole load or tick reader branches exact model records coordinates registers",index);
 require(rd(c,0xC5CD)==count&&rd(c,0xC5CB)==7&&rd(c,0xC5CC)==7&&rd(c,0xC5EA)==0x37&&rd(c,0xC5EF)==0x39&&rd(c,0xC5F0)==0x3C&&rd(c,0xC5F3)==0x5A&&rd(c,0xC5F4)==0xA5&&rd(c,0xC5F5)==0x37&&rd(c,0xC5F7)==0x39&&rd(c,0xC5D7)==0x3C&&rd(c,0xC5D8)==0x5A&&rd(c,0xFFAD)==0x61&&rd(c,0xFFAE)==0&&rd(c,0xFF9D)==5&&rd(c,0xFF9E)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0&&!memcmp(((struct GB*)c->board)->memory.rom+0x61*8192+0xEE0,originalSecondaryResources,sizeof(originalSecondaryResources)),"A12 original secondary whole read guards mapping and immutable 803 source bytes",index);
}
static uint8_t originalPairedResources[1606];
struct OriginalA12Primary {unsigned count,index,x,y,threshold,nextIndex,tx,ty,extra,dx,dy,lo,f,base,end;};
static struct OriginalA12Primary originalA12PrimaryModel(struct mCore *c,unsigned phase,unsigned frame){
 const unsigned pointers[]={0x6BCF,0x6C34,0x6D5D,0x6D9A,0x6DDB,0x6E18,0x6E49,0x6E7E,0x6EAF};const uint8_t *rom=((struct GB*)c->board)->memory.rom;unsigned ptr=pointers[phase],p=ptr+1+4*frame;struct OriginalA12Primary m={0};
 #define PRIMARY_BYTE(a) rom[0x61*8192+(a)-0x6000]
 m.count=PRIMARY_BYTE(ptr);m.index=PRIMARY_BYTE(p);if(m.index>=254){fprintf(stderr,"Primary ordinary-record model called on effect\n");exit(13);}
 m.x=(PRIMARY_BYTE(p+1)-201)&255;m.y=(PRIMARY_BYTE(p+2)-208)&255;m.threshold=PRIMARY_BYTE(p+3);p+=4;
 if(PRIMARY_BYTE(p)==255)p+=4;if(PRIMARY_BYTE(p)==254)p+=4;
 m.nextIndex=PRIMARY_BYTE(p);m.tx=(PRIMARY_BYTE(p+1)-201)&255;m.ty=(PRIMARY_BYTE(p+2)-208)&255;m.extra=PRIMARY_BYTE(p+3);m.base=ptr+1;m.end=p+4;
 m.dx=m.x>m.tx?m.x-m.tx:m.tx-m.x;m.dy=m.y>m.ty?m.y-m.ty:m.ty-m.y;m.lo=m.y<m.ty?m.y:m.ty;unsigned hi=m.y>m.ty?m.y:m.ty;m.f=0x40|(m.dy?0:0x80)|((hi&15)<(m.lo&15)?0x20:0);
 #undef PRIMARY_BYTE
 return m;
}
static void probeOriginalA12Pair(struct mCore *c,unsigned phase,unsigned frame,unsigned counter,unsigned flags,bool reset,unsigned index){
 struct SM83Core *cpu=((struct GB*)c->board)->cpu;struct OriginalA12Primary p=originalA12PrimaryModel(c,phase,frame);struct OriginalA12Secondary q=originalA12SecondaryModel(c,phase,frame);unsigned finalCounter=reset?0:counter;
 prepareA12EffectMapping(c,0x61);wr(c,0xC5A8,0);wr(c,0xC5CF,phase);wr(c,0xC5CE,reset?(counter*37)&255:frame);wr(c,0xC5CC,counter);wr(c,0xC5CD,0x37);wr(c,0xC5CB,0x39);wr(c,0xC5CA,0x3C);wr(c,0xC5D6,0x5A);wr(c,0xC5DB,0x37);wr(c,0xC5DC,0x39);wr(c,0xC5DF,0x3C);wr(c,0xC5E0,0x5A);wr(c,0xC5EA,0x37);wr(c,0xC5EF,0x39);wr(c,0xC5F0,0x3C);wr(c,0xC5F3,0x5A);wr(c,0xC5F4,0xA5);wr(c,0xC5F5,0x37);wr(c,0xC5F7,0x39);
 cpu->af=0x5A00|flags;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x6BBD;call(c,reset?0x4CFD:0x4D82);
 require(cpu->af==(p.dy<<8|p.f)&&cpu->bc==(p.lo<<8|0x37)&&cpu->de==p.base&&cpu->hl==p.end&&rd(c,0xC5CD)==p.count&&rd(c,0xC5CB)==p.threshold&&rd(c,0xC5CC)==finalCounter&&rd(c,0xC5CE)==frame&&rd(c,0xC5CF)==phase&&rd(c,0xC5D0)==p.index&&rd(c,0xC5D1)==p.nextIndex&&rd(c,0xC5D7)==p.x&&rd(c,0xC5D8)==p.y&&rd(c,0xC5D9)==p.tx&&rd(c,0xC5DA)==p.ty&&rd(c,0xC5DD)==p.dx&&rd(c,0xC5DE)==p.dy&&rd(c,0xC5FD)==p.extra&&rd(c,0xFFAD)==0x61&&rd(c,0xFF9D)==5,"Original primary reset or ordinary reader count producer exact registers geometry lookahead",index);
 call(c,0x50D8);
 require(cpu->af==(q.dy<<8|q.f)&&cpu->bc==(q.lo<<8|0x37)&&cpu->de==q.base&&cpu->hl==q.end&&rd(c,0xC5CD)==p.count&&rd(c,0xC5CB)==p.threshold&&rd(c,0xC5CC)==finalCounter&&rd(c,0xC5CE)==frame&&rd(c,0xC5CF)==phase&&rd(c,0xC5D0)==p.index&&rd(c,0xC5D1)==p.nextIndex&&rd(c,0xC5D7)==p.x&&rd(c,0xC5D8)==p.y&&rd(c,0xC5D9)==p.tx&&rd(c,0xC5DA)==p.ty&&rd(c,0xC5DD)==p.dx&&rd(c,0xC5DE)==p.dy&&rd(c,0xC5FD)==p.extra&&rd(c,0xC5EB)==q.x&&rd(c,0xC5EC)==q.y&&rd(c,0xC5ED)==q.tx&&rd(c,0xC5EE)==q.ty&&rd(c,0xC5F1)==q.dx&&rd(c,0xC5F2)==q.dy&&rd(c,0xC5F6)==q.index,"Original primary to secondary full chain count threshold counter preserved independent coordinate sets",index);
 require(rd(c,0xC5CA)==0x3C&&rd(c,0xC5D6)==0x5A&&rd(c,0xC5DB)==0x37&&rd(c,0xC5DC)==0x39&&rd(c,0xC5DF)==0x3C&&rd(c,0xC5E0)==0x5A&&rd(c,0xC5EA)==0x37&&rd(c,0xC5EF)==0x39&&rd(c,0xC5F0)==0x3C&&rd(c,0xC5F3)==0x5A&&rd(c,0xC5F4)==0xA5&&rd(c,0xC5F5)==0x37&&rd(c,0xC5F7)==0x39&&rd(c,0xFFAD)==0x61&&rd(c,0xFFAE)==0&&rd(c,0xFF9D)==0x61&&rd(c,0xFF9E)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0&&!memcmp(((struct GB*)c->board)->memory.rom+0x61*8192+0xBBD,originalPairedResources,sizeof(originalPairedResources)),"Original paired full chain guards mapping backups immutable1606 bytes",index);
}
static uint8_t originalEffectTiles[3][67];
static void probeOriginalA12Effects(struct mCore *c,unsigned phase,unsigned frame,unsigned counter,unsigned flags,unsigned plane,unsigned lcd,unsigned index){
 const unsigned pointers[]={0x6BCF,0x6C34,0x6D5D,0x6D9A,0x6DDB,0x6E18,0x6E49,0x6E7E,0x6EAF},tiles[]={0x6800,0x6837,0x6A0F},sizes[]={55,55,67};const uint8_t *rom=((struct GB*)c->board)->memory.rom;struct SM83Core *cpu=((struct GB*)c->board)->cpu;
 unsigned pos=pointers[phase]+1+4*frame,effects=0,tile=0,code=0,t=0;bool hasTile=rom[0x61*8192+pos-0x6000]==255,hasAudio=false;
 if(hasTile){tile=rom[0x61*8192+pos+2-0x6000]|rom[0x61*8192+pos+3-0x6000]<<8;pos+=4;effects++;while(t<3&&tiles[t]!=tile)t++;if(t==3)exit(14);}
 if(rom[0x61*8192+pos-0x6000]==254){hasAudio=true;code=rom[0x61*8192+pos+1-0x6000];pos+=4;effects++;}
 unsigned finalFrame=frame+effects;struct OriginalA12Primary p=originalA12PrimaryModel(c,phase,finalFrame);struct OriginalA12Secondary q=originalA12SecondaryModel(c,phase,finalFrame);const uint8_t *h=rom+0x61*8192+tile-0x6000;unsigned area=hasTile?h[2]*h[3]:0,low=hasTile?h[3]:0x37;
 prepareA12EffectMapping(c,0x61);prepareA12EffectAudio(c);wr(c,0x37FF,0x61);wr(c,0xFFAD,0x61);wr(c,0xC115,0x61);wr(c,0xCF82,0x37);
 for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}wr(c,0xFF4F,plane);
 wr(c,0xC5CF,phase);wr(c,0xC5CE,frame);wr(c,0xC5CC,counter);wr(c,0xC5CD,0x37);wr(c,0xC5CB,0x39);wr(c,0xC5CA,0x3C);wr(c,0xC5D6,0x5A);wr(c,0xC5DB,0x37);wr(c,0xC5DC,0x39);wr(c,0xC5DF,0x3C);wr(c,0xC5E0,0x5A);wr(c,0xC5E1,0x37);
 for(unsigned a=0xC5E2;a<=0xC5E8;a++)wr(c,a,0x37);for(unsigned a=0xC5F7;a<=0xC5FC;a++)wr(c,a,0x37);wr(c,0xC5EA,0x37);wr(c,0xC5EF,0x39);wr(c,0xC5F0,0x3C);wr(c,0xC5F3,0x5A);wr(c,0xC5F4,0xA5);wr(c,0xC5F5,0x37);
 cpu->af=0x5A00|flags;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x6BBD;if(lcd)wr(c,0xFF40,0x91);callWithLimit(c,0x4D82,2000000);
 require(cpu->af==(p.dy<<8|p.f)&&cpu->bc==(p.lo<<8|low)&&cpu->de==(hasTile?tile+7:p.base)&&cpu->hl==p.end&&rd(c,0xC5CD)==p.count&&rd(c,0xC5CB)==p.threshold&&rd(c,0xC5CC)==counter&&rd(c,0xC5CE)==finalFrame&&rd(c,0xC5CF)==phase&&rd(c,0xC5D0)==p.index&&rd(c,0xC5D1)==p.nextIndex&&rd(c,0xC5D7)==p.x&&rd(c,0xC5D8)==p.y&&rd(c,0xC5D9)==p.tx&&rd(c,0xC5DA)==p.ty&&rd(c,0xC5DD)==p.dx&&rd(c,0xC5DE)==p.dy&&rd(c,0xC5FD)==p.extra,"Original primary current FF FE effect chain exact output frame increments real copy audio registers",index);
 callWithLimit(c,0x50D8,2000000);
 require(cpu->af==(q.dy<<8|q.f)&&cpu->bc==(q.lo<<8|low)&&cpu->de==q.base&&cpu->hl==q.end&&rd(c,0xC5CE)==finalFrame&&rd(c,0xC5CD)==p.count&&rd(c,0xC5CB)==p.threshold&&rd(c,0xC5CC)==counter&&rd(c,0xC5D7)==p.x&&rd(c,0xC5D8)==p.y&&rd(c,0xC5DD)==p.dx&&rd(c,0xC5DE)==p.dy&&rd(c,0xC5EB)==q.x&&rd(c,0xC5EC)==q.y&&rd(c,0xC5ED)==q.tx&&rd(c,0xC5EE)==q.ty&&rd(c,0xC5F1)==q.dx&&rd(c,0xC5F2)==q.dy&&rd(c,0xC5F6)==q.index,"Original current effects to secondary original read uses advanced frame preserves primary outputs",index);
 bool exact=rd(c,0xC5CA)==0x3C&&rd(c,0xC5D6)==0x5A&&rd(c,0xC5DB)==0x37&&rd(c,0xC5DC)==0x39&&rd(c,0xC5DF)==0x3C&&rd(c,0xC5E0)==0x5A&&rd(c,0xC5E1)==0x37&&rd(c,0xC5EA)==0x37&&rd(c,0xC5EF)==0x39&&rd(c,0xC5F0)==0x3C&&rd(c,0xC5F3)==0x5A&&rd(c,0xC5F4)==0xA5&&rd(c,0xC5F5)==0x37&&rd(c,0xFFAD)==0x61&&rd(c,0xC115)==0x61&&rd(c,0xFFAB)==0x12&&rd(c,0xC113)==0x12&&rd(c,0xFF9D)==0x61&&(rd(c,0xFF4F)&1)==plane&&rd(c,0xCF82)==(hasAudio?0:0x37)&&rd(c,0xCF89)==(hasAudio?0x11:0);
 const unsigned fields[]={0xC5F9,0xC5FA,0xC5E2,0xC5E3,0xC5E6,0xC5E4,0xC5E8};for(unsigned i=0;i<7;i++)exact&=rd(c,fields[i])==(hasTile?h[i]:0x37);
 exact&=rd(c,0xC5E5)==(hasTile?0:0x37)&&rd(c,0xC5E7)==(hasTile?0:0x37)&&(rd(c,0xC5F7)<<8|rd(c,0xC5F8))==(hasTile?tile+7+2*(area&255):0x3737)&&(rd(c,0xC5FB)<<8|rd(c,0xC5FC))==(hasTile?tile+7:0x3737);
 for(unsigned i=0;i<128;i++){unsigned expected=0x5A;if(hasAudio&&i>=64&&i<80)expected=i==64?1:i==65?0xDD:i==68?8:0;exact&=rd(c,0xCF00+i)==expected;}
 exact&=!memcmp(rom+0x61*8192+0xBBD,originalPairedResources,sizeof(originalPairedResources));for(unsigned i=0;i<3;i++)exact&=!memcmp(rom+0x61*8192+tiles[i]-0x6000,originalEffectTiles[i],sizes[i]);
 exact&=(!hasAudio||code==0x82||code==0x83);
 require(exact,"Original effect chain tile state synthetic82 83 upper audio guards mapper and immutable resource bytes",index);
 wr(c,0xFF40,0);exact=true;unsigned start=hasTile?0x1800+h[0]+32*h[1]:0;
 for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){bool changed=hasTile&&i>=start&&i<start+32*h[3]&&((i-start)%32)<h[2];unsigned expected=changed?h[7+bank*area+((i-start)/32)*h[2]+(i-start)%32]:0xA5;exact&=rd(c,0x8000+i)==expected;}}
 require(exact,"Original current FF first frame both whole VRAM planes exact original geometry payload FE-only unchanged",index);

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
 /* Upper slot6: all sub90 opcodes take its audio tail, not early return. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned opcode=0;opcode<256;opcode++){
  wr(c,0xCF60,0);wr(c,0xCF61,0xD8);wr(c,0xD800,opcode);
  unsigned target=opcode<0x90?0x5026:opcode<0xA0?0x4F9F:
   opcode==0xB0?0x4F32:opcode==0xB1?0x4F14:opcode==0xC0?0x4F78:opcode==0xE0?0x4F3A:
   opcode==0xFD?0x4EEC:opcode==0xFE?0x4EFC:opcode==255?0x4EE2:0xC100;
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);
  cpu->de=0xBEEF;cpu->pc=0x4EAA;unsigned steps=0;while(cpu->pc!=target&&steps++<200)c->step(c);
  require(cpu->pc==target&&cpu->sp==(target==0xC100?0xD000:0xCFFE)&&cpu->bc==0xD801&&
          cpu->a==opcode&&cpu->de==0xBEEF&&rd(c,0xCF60)==0&&rd(c,0xCF61)==0xD8,
          "A1E slot6 all opcode dispatches",opcode);
 }
 for(unsigned index=0;index<19;index++){
  unsigned first=index<3?shortCounts[index]:extendedPrefixes[(index-3)/4];
  unsigned low=index<3?0:extendedLow[(index-3)%4];
  wr(c,0xCF60,0);wr(c,0xCF61,0xD8);wr(c,0xCF65,0x77);wr(c,0xCF54,0xA5);
  wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,first);wr(c,0xD803,low);call(c,0x4EAA);
  require(rd(c,0xCF6D)==7&&rd(c,0xCF60)==(index<3?3:4)&&rd(c,0xCF61)==0xD8&&
          rd(c,0xCF64)==(index<3?first:(low|((first&1)<<7)))&&
          rd(c,0xCF65)==(index<3?0x77:((first&0x7F)>>1))&&rd(c,0xCF54)==0xA5,
          "A1E slot6 B0 countdown preserves slot5",index);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF60,0);wr(c,0xCF61,0xD8);wr(c,0xCF89,0x2A);wr(c,0xCF88,0x37);
  wr(c,0xD800,0xB1);wr(c,0xD801,value);wr(c,0xD802,1);call(c,0x4EAA);
  require(rd(c,0xCF89)==(value<0x40?0x6A:value==0x40?0x6E:0x2E)&&rd(c,0xCF88)==0x37,
          "A1E slot6 B1 bits2 and6 in CF89",value);
 }
 for(unsigned index=0;index<32;index++){
  unsigned pointer=0xDA00+index*16;wr(c,0xD900+index*2,pointer&255);wr(c,0xD901+index*2,pointer>>8);
  for(unsigned i=0;i<16;i++)wr(c,pointer+i,(index*7+i*13+1)&255);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xFF1A,0);wr(c,0xCF60,0);wr(c,0xCF61,0xD8);wr(c,0xCF98,0);wr(c,0xCF99,0xD9);wr(c,0xCF67,0x37);
  wr(c,0xD800,0xC0);wr(c,0xD801,value);wr(c,0xD802,3);call(c,0x4EAA);
  bool wave=true;for(unsigned i=0;i<16;i++)if(rd(c,0xFF30+i)!=(((value&31)*7+i*13+1)&255))wave=false;
  require(wave&&rd(c,0xCF67)==0x37&&rd(c,0xCF60)==3&&rd(c,0xCF61)==0xD8&&rd(c,0xCF64)==3,
          "A1E slot6 C0 copies16 wave bytes without index store",value);
 }
 const unsigned loopCounts6[]={0,1,2,255};
 for(unsigned index=0;index<4;index++){
  unsigned count=loopCounts6[index];wr(c,0xCF60,0);wr(c,0xCF61,0xD8);
  wr(c,0xCF6C,count);wr(c,0xCF0C,0x77);wr(c,0xCF6A,0);wr(c,0xCF6B,0xD9);
  wr(c,0xD800,0xFE);wr(c,0xD801,5);wr(c,0xD900,3);call(c,0x4EAA);
  require(rd(c,0xCF6C)==(count>1?count-1:count)&&rd(c,0xCF0C)==0x77&&
          rd(c,0xCF60)==(count==1?2:1)&&rd(c,0xCF61)==(count==1?0xD8:0xD9)&&rd(c,0xCF64)==(count==1?5:3),
          "A1E slot6 FE updates own count retains CF0C",index);
 }
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xCF60,0);wr(c,0xCF61,0xD8);wr(c,0xCF64,1);
 wr(c,0xD800,0xB0);wr(c,0xD801,7);wr(c,0xD802,5);call(c,0x4000);
 require(rd(c,0xCF6D)==7&&rd(c,0xCF64)==5&&rd(c,0xCF60)==3&&rd(c,0xCF61)==0xD8,
         "A1E integrated tick invokes slot6 B0",0);
 /* Upper slot7: all sub90 opcodes take its audio tail, not early return. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned opcode=0;opcode<256;opcode++){
  wr(c,0xCF70,0);wr(c,0xCF71,0xD8);wr(c,0xD800,opcode);
  unsigned target=opcode<0x90?0x5177:opcode<0xA0?0x50FB:
   opcode==0xB1?0x50D5:opcode==0xC0?0x50F3:opcode==0xE0?0x506F:opcode==0xE1?0x5095:
   opcode==0xFD?0x50AD:opcode==0xFE?0x50BD:opcode==255?0x5065:0xC100;
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);
  cpu->de=0xBEEF;cpu->pc=0x502D;unsigned steps=0;while(cpu->pc!=target&&steps++<200)c->step(c);
  require(cpu->pc==target&&cpu->sp==(target==0xC100?0xD000:0xCFFE)&&cpu->bc==0xD801&&
          cpu->a==opcode&&cpu->de==0xBEEF&&rd(c,0xCF70)==0&&rd(c,0xCF71)==0xD8,
          "A1E slot7 all opcode dispatches",opcode);
 }
 for(unsigned index=0;index<19;index++){
  unsigned first=index<3?shortCounts[index]:extendedPrefixes[(index-3)/4];
  unsigned low=index<3?0:extendedLow[(index-3)%4];
  wr(c,0xCF70,0);wr(c,0xCF71,0xD8);wr(c,0xCF75,0x77);wr(c,0xCF64,0xA5);
  wr(c,0xD800,0xC0);wr(c,0xD801,7);wr(c,0xD802,first);wr(c,0xD803,low);call(c,0x502D);
  require(rd(c,0xCF77)==7&&rd(c,0xCF70)==(index<3?3:4)&&rd(c,0xCF71)==0xD8&&
          rd(c,0xCF74)==(index<3?first:(low|((first&1)<<7)))&&
          rd(c,0xCF75)==(index<3?0x77:((first&0x7F)>>1))&&rd(c,0xCF64)==0xA5,
          "A1E slot7 C0 countdown preserves slot6",index);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF70,0);wr(c,0xCF71,0xD8);wr(c,0xCF89,0x2A);wr(c,0xCF88,0x37);
  wr(c,0xD800,0xB1);wr(c,0xD801,value);wr(c,0xD802,1);call(c,0x502D);
  require(rd(c,0xCF89)==(value<0x40?0xA2:value==0x40?0xAA:0x2A)&&rd(c,0xCF88)==0x37,
          "A1E slot7 B1 bits3 and7 in CF89",value);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xCF70,0);wr(c,0xCF71,0xD8);wr(c,0xCF78,0x37);
  wr(c,0xD800,0xC0);wr(c,0xD801,value);wr(c,0xD802,3);call(c,0x502D);
  require(rd(c,0xCF77)==value&&rd(c,0xCF78)==0x37&&rd(c,0xCF70)==3&&rd(c,0xCF71)==0xD8&&rd(c,0xCF74)==3,
          "A1E slot7 C0 stores raw parameter",value);
 }
 const unsigned loopCounts7[]={0,1,2,255};
 for(unsigned index=0;index<4;index++){
  unsigned count=loopCounts7[index];wr(c,0xCF70,0);wr(c,0xCF71,0xD8);
  wr(c,0xCF7C,count);wr(c,0xCF0C,0x77);wr(c,0xCF7A,0);wr(c,0xCF7B,0xD9);
  wr(c,0xD800,0xFE);wr(c,0xD801,5);wr(c,0xD900,3);call(c,0x502D);
  require(rd(c,0xCF7C)==(count>1?count-1:count)&&rd(c,0xCF0C)==0x77&&
          rd(c,0xCF70)==(count==1?2:1)&&rd(c,0xCF71)==(count==1?0xD8:0xD9)&&rd(c,0xCF74)==(count==1?5:3),
          "A1E slot7 FE updates own count retains CF0C",index);
 }
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xCF70,0);wr(c,0xCF71,0xD8);wr(c,0xCF74,1);
 wr(c,0xD800,0xC0);wr(c,0xD801,7);wr(c,0xD802,5);call(c,0x4000);
 require(rd(c,0xCF77)==7&&rd(c,0xCF74)==5&&rd(c,0xCF70)==3&&rd(c,0xCF71)==0xD8,
         "A1E integrated tick invokes slot7 C0",0);
 const unsigned noiseBases[]={0,7,8,15,16,127,128,255};
 for(unsigned opcode=0xE0;opcode<=0xE1;opcode++)for(unsigned index=0;index<8;index++)for(unsigned value=0;value<256;value++){
  unsigned base=noiseBases[index];wr(c,0xCF70,0);wr(c,0xCF71,0xD8);wr(c,0xCF72,base);
  wr(c,0xCF7E,0x37);wr(c,0xCF7F,0x38);wr(c,0xD800,opcode);wr(c,0xD801,value);wr(c,0xD802,3);call(c,0x502D);
  unsigned expected=opcode==0xE0?((base&7)|((((base>>4)+value)&15)<<4)):
   ((base&0xF0)|(((base&7)+value)&255));
  require(rd(c,0xFF22)==expected&&rd(c,0xCF72)==base&&
          rd(c,0xCF7E)==(opcode==0xE0?value:0x37)&&rd(c,0xCF7F)==(opcode==0xE1?value:0x38)&&
          rd(c,0xCF70)==3&&rd(c,0xCF71)==0xD8&&rd(c,0xCF74)==3,
          "A1E slot7 E0 E1 original noise arithmetic",(opcode<<16)|(index<<8)|value);
 }
 const unsigned upperHandlers[]={0x4B90,0x4D23,0x4EAA,0x502D};
 for(unsigned slot=0;slot<4;slot++){
  for(unsigned i=0;i<0x80;i++)wr(c,0xCF00+i,0x5A);
  wr(c,0xCF27,0);wr(c,0xCF98,0);wr(c,0xCF99,0xD9);wr(c,0xD900,0);wr(c,0xD901,0xDA);
  for(unsigned i=0;i<16;i++)wr(c,0xDA00+i,i*7);
  unsigned offset=0x40+slot*16;wr(c,0xCF00+offset,0);wr(c,0xCF01+offset,0xD8);wr(c,0xCF89,255);wr(c,0xD800,255);
  unsigned before[128];for(unsigned i=0;i<128;i++)before[i]=rd(c,0xCF00+i);
  call(c,upperHandlers[slot]);bool exact=true;
  for(unsigned i=0;i<128;i++)if(rd(c,0xCF00+i)!=(i/16==slot+4?0:before[i]))exact=false;
  require(exact&&rd(c,0xCF89)==(255^(0x11<<slot)),"A1E full upper FF clear restore routing chain",slot);
 }
 { /* Native A1E stream setup: bounded WRAM records and every seven-bit index. */
 wr(c,0x27FF,0x1E);wr(c,0x2800,0);
 for(unsigned index=0;index<128;index++){
  wr(c,0xD200+index*2,0);wr(c,0xD201+index*2,0xD6);
 }
 for(unsigned index=0;index<127;index++)for(unsigned count=1;count<=4;count++){
  for(unsigned i=0;i<0x80;i++)wr(c,0xCF00+i,i<64?0x5A:0);
  wr(c,0xCF90,0);wr(c,0xCF91,0xD2);wr(c,0xCF80,0x80|index);
  wr(c,0xD600,count);wr(c,0xD601,0);
  for(unsigned slot=0;slot<4;slot++){
   unsigned delta=0x100+slot*16;wr(c,0xD602+slot*2,delta>>8);wr(c,0xD603+slot*2,delta&255);
   wr(c,0xD600+delta,7+slot);
  }
  call(c,0x4003);bool exact=true;
  for(unsigned i=0;i<64;i++){
   unsigned slot=i/16,field=i%16,expected=0;
   if(slot<count){if(field==0)expected=1+slot*16;else if(field==1)expected=0xD7;else if(field==4)expected=8+slot;}
   if(rd(c,0xCF00+i)!=expected||rd(c,0xCFA0+i)!=0x5A)exact=false;
  }
  require(exact&&rd(c,0xCF80)==0&&rd(c,0xCF88)==255,"A1E lower relative streams backup and install",index*4+count);
 }
 for(unsigned index=0;index<128;index++)for(unsigned channel=1;channel<=4;channel++){
  for(unsigned i=0;i<128;i++)wr(c,0xCF00+i,0x5A);
  wr(c,0xCF92,0);wr(c,0xCF93,0xD2);wr(c,0xCF82,0x80|index);wr(c,0xCF89,0);
  wr(c,0xD600,channel);wr(c,0xD601,0);wr(c,0xD605,0);wr(c,0xD606,0xD7);wr(c,0xD700,7);
  call(c,0x4006);bool exact=true;unsigned offset=0x30+channel*16;
  for(unsigned i=0;i<128;i++){
   unsigned expected=0x5A;
   if(i>=offset&&i<offset+16){expected=i==offset?1:i==offset+1?0xD7:i==offset+4?8:0;}
   if(rd(c,0xCF00+i)!=expected)exact=false;
  }
  require(exact&&rd(c,0xCF82)==0&&rd(c,0xCF89)==(0x11<<(channel-1)),"A1E upper channel record installs exact slot",index*4+channel);
 }
 for(unsigned value=0;value<128;value++)for(unsigned which=0;which<2;which++){
  for(unsigned i=0;i<128;i++)wr(c,0xCF00+i,0x5A);
  wr(c,0xCF80,value);wr(c,0xCF82,value);call(c,which?0x4006:0x4003);
  bool exact=true;for(unsigned i=0;i<128;i++)if(rd(c,0xCF00+i)!=0x5A)exact=false;
  require(exact&&rd(c,0xCF80)==value&&rd(c,0xCF82)==value,"A1E inactive setup requests do nothing",which*128+value);
 }
 /* Initialization reads literal bytes at5000, overlapping slot6 code; no remap. */
 const unsigned initFields[]={0xCF92,0xCF93,0xCF90,0xCF91,0xCF94,0xCF95,0xCF96,0xCF97,0xCF98,0xCF99,0xCF9A,0xCF9B};
 unsigned initBytes[12];for(unsigned i=0;i<12;i++)initBytes[i]=rd(c,0x5000+i);
 call(c,0x4009);bool initExact=true;for(unsigned i=0;i<12;i++)if(rd(c,initFields[i])!=initBytes[i])initExact=false;
 require(initExact&&rd(c,0xCF84)==255&&rd(c,0xCF88)==255&&rd(c,0xCF89)==0,"A1E literal pointer initialization",0);
 for(unsigned i=0;i<128;i++)wr(c,0xCF00+i,0x5A);wr(c,0xCEFF,0x37);wr(c,0xCF80,0x38);call(c,0x4062);
 bool cleared=true;for(unsigned i=0;i<128;i++)if(rd(c,0xCF00+i)!=0)cleared=false;
 require(cleared&&rd(c,0xCEFF)==0x37&&rd(c,0xCF80)==0x38,"A1E clear128 retains guards",0);
 wr(c,0xD900,0x34);wr(c,0xD901,0x12);wr(c,0xD902,0x77);cpu->de=0xD900;cpu->bc=0xBEEF;call(c,0x405B);
 require(cpu->hl==0x1234&&cpu->de==0xD902&&cpu->bc==0xBEEF&&rd(c,0xD902)==0x77,"A1E DE word read increments2",0);
 /* FF lower request resumes the64-byte backup; wave source is synthetic. */
 for(unsigned i=0;i<128;i++)wr(c,0xCF00+i,0x5A);
 for(unsigned i=0;i<64;i++)wr(c,0xCFA0+i,i==0x27?0:i+1);
 wr(c,0xCF98,0);wr(c,0xCF99,0xD9);wr(c,0xD900,0);wr(c,0xD901,0xDA);
 for(unsigned i=0;i<16;i++)wr(c,0xDA00+i,i*7);
 wr(c,0xCF80,255);call(c,0x4003);bool resumed=true;
 for(unsigned i=0;i<128;i++)if(rd(c,0xCF00+i)!=(i<64?(i==0x27?0:i+1):0x5A))resumed=false;
 require(resumed&&rd(c,0xCF80)==0&&rd(c,0xCF88)==255,"A1E FF request resumes lower backup",0);
 /* Install four streams then execute their countdowns into measured handlers. */
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xCF90,0);wr(c,0xCF91,0xD2);wr(c,0xCF80,0x80);wr(c,0xD600,4);
 for(unsigned slot=0;slot<4;slot++){
  unsigned delta=0x100+slot*16,address=0xD600+delta;
  wr(c,0xD602+slot*2,delta>>8);wr(c,0xD603+slot*2,delta&255);
  wr(c,address,1);wr(c,address+1,slot==3?0xC0:0xB0);wr(c,address+2,7);wr(c,address+3,5);
 }
 call(c,0x4003);call(c,0x4000);call(c,0x4000);bool streamsIntegrated=true;
 for(unsigned slot=0;slot<4;slot++)if(rd(c,0xCF00+slot*16)!=(4+slot*16)||rd(c,0xCF01+slot*16)!=0xD7||rd(c,0xCF04+slot*16)!=5)streamsIntegrated=false;
 require(streamsIntegrated,"A1E relative stream setup into tick and four handlers",0);
 }
 { /* Resident pointer loader and full request wrappers, synthetic records. */
 const unsigned pointerFields[]={0xCF92,0xCF93,0xCF90,0xCF91,0xCF94,0xCF95,0xCF96,0xCF97,0xCF98,0xCF99,0xCF9A,0xCF9B};
 const unsigned sourceBanks[]={0,0x14,0x16};
 for(unsigned index=0;index<3;index++){
  unsigned bank=sourceBanks[index];wr(c,0x37FF,bank);wr(c,0x3800,0);
  unsigned bytes[12];for(unsigned i=0;i<12;i++)bytes[i]=rd(c,0x6000+i);
  wr(c,0xFFAD,4);wr(c,0xFFAE,0);wr(c,0x37FF,4);wr(c,0x3800,0);unsigned old=rd(c,0x6010);
  cpu->de=bank;cpu->hl=0x6000;cpu->bc=0xBEEF;call(c,0x21D7);bool exact=true;
  for(unsigned i=0;i<12;i++)if(rd(c,pointerFields[i])!=bytes[i])exact=false;
  require(exact&&cpu->hl==0x600C&&cpu->de==bank&&cpu->bc==0xBEEF&&
          rd(c,0xC663)==bank&&rd(c,0xC664)==0&&rd(c,0xC666)==bank&&rd(c,0xC667)==0&&
          rd(c,0xC115)==4&&rd(c,0xC116)==0&&rd(c,0x6010)==old,
          "resident A1E pointers read mapped B and restore previous B",bank);
 }
 for(unsigned map=0;map<2;map++)for(unsigned index=0;index<2;index++)for(unsigned count=1;count<=4;count++){
  unsigned select=index?126:0,aBank=map?0x16:4,bBank=map?0x14:8;
  wr(c,0xFFAB,aBank);wr(c,0xFFAC,0);wr(c,0xFFAD,bBank);wr(c,0xFFAE,0);
  wr(c,0x27FF,aBank);wr(c,0x2800,0);wr(c,0x37FF,bBank);wr(c,0x3800,0);
  unsigned aByte=rd(c,0x4010),bByte=rd(c,0x6010);
  for(unsigned i=0;i<128;i++)wr(c,0xCF00+i,i<64?0x5A:0);
  wr(c,0xC663,0x14);wr(c,0xC664,0);wr(c,0xCF90,0);wr(c,0xCF91,0xD2);
  wr(c,0xD200+select*2,0);wr(c,0xD201+select*2,0xD6);wr(c,0xD600,count);wr(c,0xD601,0);
  for(unsigned slot=0;slot<4;slot++){unsigned delta=0x100+slot*16;wr(c,0xD602+slot*2,delta>>8);wr(c,0xD603+slot*2,delta&255);wr(c,0xD600+delta,7+slot);}
  unsigned af=((0x80|select)<<8)|0xB0;cpu->af=af;cpu->bc=0xBEEF;cpu->de=0xCAFE;cpu->hl=0xD123;call(c,0x22A7);
  bool exact=true;for(unsigned i=0;i<64;i++){unsigned slot=i/16,field=i%16,expected=0;if(slot<count){if(field==0)expected=1+slot*16;else if(field==1)expected=0xD7;else if(field==4)expected=8+slot;}if(rd(c,0xCF00+i)!=expected||rd(c,0xCFA0+i)!=0x5A)exact=false;}
  require(exact&&cpu->af==af&&cpu->bc==0xBEEF&&cpu->de==0xCAFE&&cpu->hl==0xD123&&
          rd(c,0xC113)==aBank&&rd(c,0xC114)==0&&rd(c,0xC115)==bBank&&rd(c,0xC116)==0&&
          rd(c,0x4010)==aByte&&rd(c,0x6010)==bByte&&rd(c,0xCF80)==0&&rd(c,0xC665)==(0x80|select)&&rd(c,0xC66B)==(0x80|select),
          "resident lower request complete stream setup and mapper/register restore",map*8+index*4+count);
 }
 for(unsigned map=0;map<2;map++)for(unsigned channel=1;channel<=4;channel++){
  unsigned aBank=map?0x16:4,bBank=map?0x14:8;
  wr(c,0xFFAB,aBank);wr(c,0xFFAC,0);wr(c,0xFFAD,bBank);wr(c,0xFFAE,0);
  wr(c,0x27FF,aBank);wr(c,0x2800,0);wr(c,0x37FF,bBank);wr(c,0x3800,0);
  unsigned aByte=rd(c,0x4010),bByte=rd(c,0x6010);
  for(unsigned i=0;i<128;i++)wr(c,0xCF00+i,0x5A);
  wr(c,0xC663,0x14);wr(c,0xC664,0);wr(c,0xCF92,0);wr(c,0xCF93,0xD3);wr(c,0xCF89,0);
  wr(c,0xD300,0x10);wr(c,0xD301,0xD6);wr(c,0xD610,channel);wr(c,0xD611,0);wr(c,0xD615,0);wr(c,0xD616,0xD7);wr(c,0xD700,7);
  cpu->af=0x80B0;cpu->bc=0xBEEF;cpu->de=0xCAFE;cpu->hl=0xD123;call(c,0x230C);
  bool exact=true;unsigned offset=0x30+channel*16;for(unsigned i=0;i<128;i++){unsigned expected=0x5A;if(i>=offset&&i<offset+16)expected=i==offset?1:i==offset+1?0xD7:i==offset+4?8:0;if(rd(c,0xCF00+i)!=expected)exact=false;}
  require(exact&&cpu->af==0x80B0&&cpu->bc==0xBEEF&&cpu->de==0xCAFE&&cpu->hl==0xD123&&
          rd(c,0xC113)==aBank&&rd(c,0xC114)==0&&rd(c,0xC115)==bBank&&rd(c,0xC116)==0&&
          rd(c,0x4010)==aByte&&rd(c,0x6010)==bByte&&rd(c,0xCF82)==0&&rd(c,0xCF89)==(0x11<<(channel-1)),
          "resident upper request complete setup mapper/register restore",map*4+channel);
 }
 /* Combined resident request followed by resident tick enters both handlers. */
 for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);
 wr(c,0xC663,0x14);wr(c,0xC664,0);wr(c,0xC672,0);
 wr(c,0xCF90,0);wr(c,0xCF91,0xD2);wr(c,0xCF92,0);wr(c,0xCF93,0xD3);
 wr(c,0xD200,0);wr(c,0xD201,0xD6);wr(c,0xD600,1);wr(c,0xD602,1);wr(c,0xD603,0);
 wr(c,0xD300,0x10);wr(c,0xD301,0xD6);wr(c,0xD610,1);wr(c,0xD611,0);wr(c,0xD615,0x10);wr(c,0xD616,0xD7);
 for(unsigned slot=0;slot<2;slot++){unsigned address=0xD700+slot*16;wr(c,address,1);wr(c,address+1,0xB0);wr(c,address+2,7+slot);wr(c,address+3,5);}
 cpu->af=0x37B0;cpu->bc=0xBEEF;cpu->de=0xCAFE;cpu->hl=0xD123;call(c,0x235F);
 require(rd(c,0xCF04)==1&&rd(c,0xCF44)==1&&rd(c,0xC665)==0&&rd(c,0xC666)==0&&rd(c,0xC667)==0&&rd(c,0xC66B)==0&&
         cpu->af==0x37B0&&cpu->bc==0xBEEF&&cpu->de==0xCAFE&&cpu->hl==0xD123,"resident combined request setup and first tick",0);
 call(c,0x2242);require(rd(c,0xCF0D)==7&&rd(c,0xCF4D)==8&&rd(c,0xCF04)==5&&rd(c,0xCF44)==5&&rd(c,0xCF00)==4&&rd(c,0xCF40)==0x14,
                       "resident tick after combined setup reaches both B0 handlers",0);
 wr(c,0xC665,255);wr(c,0xC666,255);wr(c,0xC667,255);wr(c,0xC66B,255);call(c,0x23CC);
 require(rd(c,0xCF86)==2&&rd(c,0xCF87)==1&&rd(c,0xC665)==0&&rd(c,0xC666)==0&&rd(c,0xC667)==0&&rd(c,0xC66B)==0,
         "resident global countdown request fields",0);
 }
 { /* Published main-state B sources, actual ROM records with forced entry. */
 const unsigned banks[]={0x21,0x5B,0x5C},records[]={0x662E,0x65D4,0x662E};
 const unsigned prefixEnds[3][4]={{0x6642,0x691d,0x6bb2,0x6d3b},{0x65eb,0x698c,0x6cd1,0x6eca},{0x6642,0x6862,0x7037,0x77be}};
 const unsigned prefixDurations[3][4]={{11,11,36,24},{27,14,29,2},{59,7,5,1}};
 const unsigned bodyEnds[3][4]={{0x690F,0x6BA4,0x6D2B,0x6FFC},{0x697B,0x6CC0,0x6EB9,0x7255},{0x6854,0x7029,0x77B0,0x7E3A}};
 const unsigned bodyStopPointers[3][4]={{0x690F,0x6BA4,0x6D29,0x6FFC},{0x697B,0x6CC0,0x6EB9,0x7255},{0x6854,0x7029,0x77B0,0x7E3A}};
 const unsigned edgeSavedPointers[3][4]={{0x663E,0x6919,0x6BAE,0x6D35},{0x65E7,0x6988,0x6CCD,0x6EC6},{0x6669,0x6901,0x7126,0x788A}};
 const unsigned edgeRestartPointers[3][4]={{0x6642,0x691D,0x6BB2,0x6D3B},{0x65EB,0x698C,0x6CD1,0x6ECA},{0x666D,0x6905,0x712D,0x788E}};
 const unsigned handlers[]={0x43E7,0x45A1,0x4752,0x48EC};
 const unsigned bodyEventCounts[3][4]={{215,201,106,246},{352,315,195,285},{195,588,699,599}};
 struct A1EEvent negativeEvents[800];unsigned negativeCount;
 wr(c,0xD800,0x80);wr(c,0xD801,7);
 require(a1eLinearEvents(c,0,0xD800,0xD802,negativeEvents,&negativeCount)&&negativeCount==1,
         "A1E bounded framing positive fixture",0);
 require(!a1eLinearEvents(c,0,0xD800,0xD801,negativeEvents,&negativeCount),"A1E truncated duration rejected",0);
 wr(c,0xD800,0xA0);
 require(!a1eLinearEvents(c,0,0xD800,0xD802,negativeEvents,&negativeCount),"A1E unsupported opcode rejected",0);
 wr(c,0xD800,0x90);wr(c,0xD801,7);wr(c,0xD802,0x81);
 require(!a1eLinearEvents(c,0,0xD800,0xD803,negativeEvents,&negativeCount),"A1E truncated long duration rejected",0);

 const unsigned fields[]={0xCF92,0xCF93,0xCF90,0xCF91,0xCF94,0xCF95,0xCF96,0xCF97,0xCF98,0xCF99,0xCF9A,0xCF9B};
 for(unsigned index=0;index<3;index++){
  unsigned bank=banks[index];wr(c,0x37FF,bank);wr(c,0x3800,0);
  struct A1EEvent bodyEvents[4][800];unsigned counts[4];
  for(unsigned slot=0;slot<4;slot++)
   require(a1eLinearEvents(c,slot,prefixEnds[index][slot],bodyEnds[index][slot],bodyEvents[slot],&counts[slot])&&
           counts[slot]==bodyEventCounts[index][slot]&&bodyEvents[slot][counts[slot]-1].pointer==bodyStopPointers[index][slot]&&
           rd(c,bodyEnds[index][slot])==0xFE,
           "actual B bounded body framing and FE frontier",bank*4+slot);
  unsigned header[12],streams[4],durations[4];for(unsigned i=0;i<12;i++)header[i]=rd(c,0x6000+i);
  unsigned table=header[2]|(header[3]<<8),record=rd(c,table+2)|(rd(c,table+3)<<8);
  require(record==records[index]&&rd(c,record)==4,"actual B lower index1 four-stream record",bank);
  for(unsigned slot=0;slot<4;slot++){unsigned delta=(rd(c,record+2+slot*2)<<8)|rd(c,record+3+slot*2);streams[slot]=(record+delta)&65535;durations[slot]=rd(c,streams[slot]);}
  wr(c,0xFFAB,4);wr(c,0xFFAC,0);wr(c,0xFFAD,8);wr(c,0xFFAE,0);
  wr(c,0x27FF,4);wr(c,0x2800,0);wr(c,0x37FF,8);wr(c,0x3800,0);
  for(unsigned i=0;i<0x90;i++)wr(c,0xCF00+i,0);wr(c,0xC672,0);
  cpu->hl=0x6000;cpu->de=bank;call(c,0x246);bool exact=true;
  for(unsigned i=0;i<12;i++)if(rd(c,fields[i])!=header[i])exact=false;
  require(exact&&rd(c,0xC663)==bank&&rd(c,0xC664)==0,"actual B header through resident thunk",bank);
  cpu->a=0x81;call(c,0x24C);exact=true;
  for(unsigned slot=0;slot<4;slot++){unsigned pointer=rd(c,0xCF00+slot*16)|(rd(c,0xCF01+slot*16)<<8);if(pointer!=streams[slot]+1||rd(c,0xCF04+slot*16)!=((durations[slot]+1)&255))exact=false;}
  require(exact&&rd(c,0xCF80)==0&&rd(c,0xC113)==4&&rd(c,0xC115)==8,"actual B lower stream offsets through resident request",bank);
  call(c,0x2242);exact=true;
  for(unsigned slot=0;slot<4;slot++){unsigned pointer=rd(c,0xCF00+slot*16)|(rd(c,0xCF01+slot*16)<<8);if(pointer!=prefixEnds[index][slot]||rd(c,0xCF04+slot*16)!=prefixDurations[index][slot])exact=false;}
  require(exact&&rd(c,0xC113)==4&&rd(c,0xC115)==8,"actual B first tick consumes bounded command prefixes",bank);
  const unsigned slot0Records[3][3]={{0,0x40,2},{0,0x83,1},{0,0x83,1}};
  const unsigned slot1Records[3][2]={{0x83,5},{0x80,2},{0xE0,2}};
  const unsigned waveIndices[]={4,2,6},wavePointers[]={0x60BB,0x609B,0x60DB};
  exact=true;
  for(unsigned i=0;i<3;i++)if(rd(c,0xCF07+i)!=slot0Records[index][i])exact=false;
  for(unsigned i=0;i<2;i++)if(rd(c,0xCF17+i)!=slot1Records[index][i])exact=false;
  require(exact&&rd(c,0xCF27)==waveIndices[index],"actual B C0 selected slot0/1 records and slot2 index",bank);
  /* Run full resident ticks, independently advancing the low/high counters.
     Disable each slot only after its final event is loaded, before FE executes. */
  unsigned savedSlotState[4][16];
  unsigned next[4]={0},modelLow[4],modelHigh[4]={0},modelPointer[4],done=0,executedTicks=0;
  for(unsigned slot=0;slot<4;slot++){modelLow[slot]=prefixDurations[index][slot];modelPointer[slot]=prefixEnds[index][slot];}
  for(unsigned tick=0;done!=15&&tick<20000;tick++){
   for(unsigned slot=0;slot<4;slot++)if(!(done&(1<<slot))){
    modelLow[slot]=(modelLow[slot]-1)&255;
    if(!modelLow[slot]){
     if(modelHigh[slot]){modelHigh[slot]--;modelLow[slot]=255;}
     else{
      require(next[slot]<counts[slot],"A1E model stays within linear body",bank*4+slot);
      struct A1EEvent event=bodyEvents[slot][next[slot]++];
      modelLow[slot]=event.low;modelHigh[slot]=event.high;modelPointer[slot]=event.pointer;
     }
    }
   }
   call(c,0x2242);executedTicks++;exact=true;
   for(unsigned slot=0;slot<4;slot++)if(!(done&(1<<slot))){
    unsigned base=0xCF00+slot*16,pointer=rd(c,base)|(rd(c,base+1)<<8);
    if(pointer!=modelPointer[slot]||rd(c,base+4)!=modelLow[slot]||rd(c,base+5)!=modelHigh[slot])exact=false;
   }
   require(exact&&rd(c,0xC113)==4&&rd(c,0xC115)==8,
           "actual B linear body resident tick matches independent framing counters",bank*20000+tick);
   for(unsigned slot=0;slot<4;slot++)if(!(done&(1<<slot))&&next[slot]==counts[slot]){
    require(modelPointer[slot]==bodyStopPointers[index][slot],"actual B stops before FE or zero-count tail",bank*4+slot);
    unsigned base=0xCF00+slot*16,saved=rd(c,base+10)|(rd(c,base+11)<<8);
    require(saved==edgeSavedPointers[index][slot]&&rd(c,base+12)==0,
            "actual B final original FD pointer and zero loop count",bank*4+slot);
    for(unsigned i=0;i<16;i++)savedSlotState[slot][i]=rd(c,base+i);
    done|=1<<slot;wr(c,0xCF01+slot*16,0);
   }
  }
  require(done==15,"actual B all four linear bodies bounded",bank);
  printf("A1E B%02X bounded linear bodies: %u resident ticks; stopped before FE\n",bank,executedTicks);
  /* Original FE restart from the retained final event state. The slot2 B21
     zero-count tail is included; other slots enter FE directly. No IRQ claim. */
  wr(c,0x27FF,0x1E);wr(c,0x2800,0);wr(c,0x37FF,bank);wr(c,0x3800,0);
  for(unsigned slot=0;slot<4;slot++){
   unsigned base=0xCF00+slot*16;
   for(unsigned i=0;i<16;i++)wr(c,base+i,savedSlotState[slot][i]);
   call(c,handlers[slot]);
   unsigned pointer=rd(c,base)|(rd(c,base+1)<<8),saved=rd(c,base+10)|(rd(c,base+11)<<8);
   require(pointer==edgeRestartPointers[index][slot]&&rd(c,base+4)==prefixDurations[index][slot]&&
           rd(c,base+5)==0&&saved==edgeSavedPointers[index][slot]&&rd(c,base+12)==0,
           "actual B FE zero-count restart uses original saved pointer",bank*4+slot);
   /* Independent forced count1 makes the original00 countdown reach FF.
      This is fallback reachability, not an original zero-count exit. */
   for(unsigned i=0;i<16;i++)wr(c,base+i,savedSlotState[slot][i]);
   wr(c,base,bodyEnds[index][slot]&255);wr(c,base+1,bodyEnds[index][slot]>>8);wr(c,base+12,1);
   unsigned before=rd(c,base-1),after=rd(c,base+16);call(c,handlers[slot]);exact=true;
   for(unsigned i=0;i<16;i++)if(rd(c,base+i))exact=false;
   require(exact&&rd(c,base-1)==before&&rd(c,base+16)==after,
           "actual B forced FE count1 reaches original FF exact16 clear",bank*4+slot);
  }
  /* Separate forced slot2 C0 entry with channel disabled: exact wave copy,
     without inferring first-tick audio access or audible output. */
  wr(c,0x27FF,0x1E);wr(c,0x2800,0);wr(c,0x37FF,bank);wr(c,0x3800,0);
  unsigned wave[16];for(unsigned i=0;i<16;i++)wave[i]=rd(c,wavePointers[index]+i);
  wr(c,0xFF1A,0);wr(c,0xD800,waveIndices[index]);wr(c,0xD801,7);cpu->bc=0xD800;
  call(c,0x4825);exact=true;
  for(unsigned i=0;i<16;i++)if(rd(c,0xFF30+i)!=wave[i])exact=false;
  require(exact&&rd(c,0xCF27)==waveIndices[index]&&rd(c,0xCF24)==7,
          "actual B C0 selected pointer copies16 original wave bytes channel disabled",bank);


 }
 }
 { /* A16 menu helper units; LCD disabled and interrupts suppressed. */
 wr(c,0x27FF,0x16);wr(c,0x2800,0);wr(c,0xFF40,0);
 const unsigned zeroFields[]={0xC1C2,0xC1C4,0xC5A4,0xC5A5,0xC5A9};
 for(unsigned pattern=0;pattern<2;pattern++)for(unsigned initialPlane=0;initialPlane<2;initialPlane++){
  unsigned value=pattern?0x5A:0xA5;
  for(unsigned i=0;i<5;i++)wr(c,zeroFields[i],value);
  wr(c,0xC5A3,value);wr(c,0xC1C3,0x37);wr(c,0xC1C5,0x38);wr(c,0xC5A6,0x39);wr(c,0xFF4F,initialPlane);
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x4AF0;
  unsigned steps=0;while(cpu->pc!=0x4B07&&steps++<100)c->step(c);
  bool exact=true;for(unsigned i=0;i<5;i++)if(rd(c,zeroFields[i]))exact=false;
  require(cpu->pc==0x4B07&&cpu->sp==0xCFFE&&exact&&rd(c,0xC5A3)==1&&
          (rd(c,0xFF4F)&1)==0&&rd(c,0xC1C3)==0x37&&rd(c,0xC1C5)==0x38&&rd(c,0xC5A6)==0x39,
          "A16 menu initialization prefix stops before SYS0 resource call",pattern*2+initialPlane);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);wr(c,0x97FF,0x37+plane);wr(c,0x9C00,0x39+plane);
   for(unsigned i=0;i<1024;i++)wr(c,0x9800+i,value);
  }
  wr(c,0xFF4F,initialPlane);call(c,0x4B36);
  exact=cpu->hl==0x9C00&&cpu->bc==0&&(rd(c,0xFF4F)&1)==1;
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   if(rd(c,0x97FF)!=0x37+plane||rd(c,0x9C00)!=0x39+plane)exact=false;
   for(unsigned i=0;i<1024;i++)if(rd(c,0x9800+i)!=(plane?0:0x80))exact=false;
  }
  require(exact,"A16 LCD-off background fills1024 cells on both planes with guards",pattern*2+initialPlane);
 }
 for(unsigned mode=0;mode<2;mode++){
  unsigned value=mode?0x5A:0xA5;
  wr(c,0xFF8E,value);wr(c,0xFF8F,value);wr(c,0xFF92,value);wr(c,0xFF93,value);
  wr(c,0xC67F,0xC3);wr(c,0xC680,0x37);wr(c,0xC681,0x38);
  wr(c,0xC682,0xC3);wr(c,0xC683,0x39);wr(c,0xC684,0x3A);
  call(c,0x4B21);
  require(rd(c,0xFF8E)==0x91&&rd(c,0xFF8F)==0x4B&&rd(c,0xFF92)==0&&rd(c,0xFF93)==0&&
          rd(c,0xC67F)==0xD9&&rd(c,0xC680)==0x37&&rd(c,0xC681)==0x38&&
          rd(c,0xC682)==0xD9&&rd(c,0xC683)==0x39&&rd(c,0xC684)==0x3A,
          "A16 independent setup tail installs4B91 callback and empty interrupt stubs",mode);
  wr(c,0xC219,value);wr(c,0xC21A,value);wr(c,0xC1C2,value);wr(c,0xC1C4,0x73);
  call(c,0x4B78);
  require(rd(c,0xFF8E)==0&&rd(c,0xFF8F)==0&&rd(c,0xFF92)==0&&rd(c,0xFF93)==0&&
          rd(c,0xC67F)==0xD9&&rd(c,0xC682)==0xD9&&rd(c,0xC219)==0&&rd(c,0xC21A)==0&&
          rd(c,0xC1C2)==0&&rd(c,0xC1C4)==0x73,
          "A16 full callback clear also clears2723 pointer and C1C2",mode);
 }
 const unsigned callbackA[]={0,1,255};
 for(unsigned mode=0;mode<3;mode++){
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->a=callbackA[mode];cpu->pc=0x41EA;
  unsigned target=mode?0x4223:0x41F3,steps=0;while(cpu->pc!=target&&steps++<100)c->step(c);
  require(cpu->pc==target&&cpu->sp==0xCFFE&&cpu->de==(mode?0x4F5A:0x3ED8)&&
          (mode?cpu->a==0x0D:cpu->bc==0x02A3),
          "A16 status callback branch prefix stops before storage/display callee",mode);
 }
 }
 { /* A16 installed refresh, full paths with LCD off and DMA stub. */
 wr(c,0x27FF,0x16);wr(c,0x2800,0);wr(c,0xFF40,0);wr(c,0xFF80,0xC9);wr(c,0xC221,0);
 const unsigned requests[]={0,1,0x80,255};
 for(unsigned bank=1;bank<=3;bank+=2)for(unsigned mode=0;mode<4;mode++){
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);wr(c,0x97FF,0x37+plane);wr(c,0x9C00,0x39+plane);
   for(unsigned i=0;i<1024;i++)wr(c,0x9800+i,0xA5);
  }
  wr(c,0xFF70,7);for(unsigned i=0;i<168;i++)wr(c,0xD000+i,(i*13+bank)&255);
  wr(c,0xFF70,bank);wr(c,0xFF4F,1);wr(c,0xC5A9,requests[mode]);wr(c,0xC63A,0x38);
  call(c,0x4B91);
  bool exact=rd(c,0xC5A9)==0&&(rd(c,0xFF70)&7)==bank&&(rd(c,0xFF4F)&1)==(mode?0:1)&&rd(c,0xC63A)==(mode?7:0x38);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   if(rd(c,0x97FF)!=0x37+plane||rd(c,0x9C00)!=0x39+plane)exact=false;
   for(unsigned i=0;i<1024;i++){
    unsigned row=i/32,column=i%32,expected=0xA5;
    if(mode&&row<6&&column<14)expected=((plane*84+row*14+column)*13+bank)&255;
    if(mode&&row==17&&column>=15&&column<19)expected=plane?0:0x81+column-15;
    if(rd(c,0x9800+i)!=expected)exact=false;
   }
  }
  require(exact,"A16 full refresh pending/nonpending two planes overlay and WRAM restore",bank*4+mode);
 }
 /* Direct helper tests include bit7 background-base selection and banks3/7. */
 for(unsigned sourceBank=3;sourceBank<=7;sourceBank+=4)for(unsigned high=0;high<2;high++){
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);for(unsigned i=0;i<2048;i++)wr(c,0x9800+i,0xA5);
  }
  wr(c,0xFF70,sourceBank);for(unsigned i=0;i<16;i++)wr(c,0xD000+i,i*7+sourceBank);
  wr(c,0xFF70,1);wr(c,0xFF4F,1);wr(c,0xC63A,sourceBank|(high?0x80:0));
  cpu->bc=0x0302;cpu->hl=0x0402;cpu->de=0xD000;call(c,0x4391);
  bool exact=(rd(c,0xFF70)&7)==1&&(rd(c,0xFF4F)&1)==0;
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned i=0;i<2048;i++){
    unsigned local=i-(high?1024:0),row=local/32,column=local%32,expected=0xA5;
    if(i>=(high?1024:0)&&row>=2&&row<4&&column>=3&&column<7)
     expected=(plane*8+(row-2)*4+column-3)*7+sourceBank;
    if(rd(c,0x9800+i)!=expected)exact=false;
   }
  }
  require(exact,"A16 banked rectangle dimensions origin basebit and two-plane source order",sourceBank*2+high);
 }
 }
 { /* A16 field dispatcher and numeric handlers, before presentation. */
 wr(c,0x27FF,0x16);wr(c,0x2800,0);wr(c,0xFF40,0);
 const unsigned targets[]={0x4BED,0x4BFF,0x4C11,0x4C23,0x4C3A,0x4C51,0x4C63,0x4C75};
 const unsigned fields[]={0xC73D,0xC73E,0xC73F,0xC747,0xC745,0xC84B,0xC84C,0xC84D};
 const unsigned stops[]={0x4BFB,0x4C0D,0x4C1F,0x4C36,0x4C4D,0x4C5F,0x4C71,0x4C83};
 for(unsigned index=0;index<256;index++){
  unsigned address=0x4BDD+((index*2)&255),target=rd(c,address)|(rd(c,address+1)<<8);
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->a=index;cpu->pc=0x4BCA;
  unsigned steps=0;while(cpu->pc!=0x4BDB&&steps++<100)c->step(c);
  require(cpu->pc==0x4BDB&&cpu->hl==target&&cpu->de==target&&cpu->sp==0xCFFC&&
          rd(c,0xCFFC)==0xDC&&rd(c,0xCFFD)==0x4B&&(index>=8||target==targets[index]),
          "A16 field dispatch wraps doubled byte index and pushes return",index);
 }
 const unsigned words[]={0,1,9,10,99,100,101,255,256,999,1000,9999,10000,25599,25600,25601,65534,65535};
 for(unsigned slot=0;slot<8;slot++){
  unsigned word=slot==3||slot==4,n=word?sizeof(words)/sizeof(words[0]):256;
  for(unsigned sample=0;sample<n;sample++){
   unsigned value=word?words[sample]:sample,expected[5],length=a16ExpectedField(value,word,expected);
   wr(c,fields[slot],value&255);if(word)wr(c,fields[slot]+1,value>>8);
   for(unsigned i=0;i<8;i++)wr(c,0xC654+i,0xA5);
   struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;
   cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=targets[slot];
   unsigned steps=0;while(cpu->pc!=stops[slot]&&steps++<2000)c->step(c);
   bool exact=cpu->pc==stops[slot]&&cpu->sp==0xCFFE&&cpu->hl==0xC655;
   for(unsigned i=0;i<length;i++)if(rd(c,0xC655+i)!=expected[i])exact=false;
   require(exact&&rd(c,0xC654)==0xA5&&rd(c,0xC655+length)==0xA5,
           "A16 field numeric tiles and terminator before presentation",slot*65536+value);
  }
  /* The eight measured entries run through the actual table dispatcher. */
  unsigned value=word?100:42,expected[5],length=a16ExpectedField(value,word,expected);
  wr(c,fields[slot],value&255);if(word)wr(c,fields[slot]+1,value>>8);
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->a=slot;cpu->pc=0x4BCA;
  unsigned steps=0;while(cpu->pc!=stops[slot]&&steps++<2000)c->step(c);
  bool exact=cpu->pc==stops[slot]&&cpu->sp==0xCFFC&&cpu->hl==0xC655;
  for(unsigned i=0;i<length;i++)if(rd(c,0xC655+i)!=expected[i])exact=false;
  require(exact&&rd(c,0xCFFC)==0xDC&&rd(c,0xCFFD)==0x4B,
          "A16 eight table entries reach presentation with formatted tiles",slot);
 }
 }
 { /* Complete byte domains and word arithmetic contracts. */
 for(unsigned left=0;left<256;left++)for(unsigned right=0;right<256;right++){
  cpu->a=left;cpu->bc=0xA500|right;cpu->de=0xBEEF;cpu->hl=0xD234;call(c,0x22B);
  require(cpu->a==((left*right)&255)&&cpu->bc==right&&cpu->de==0xBEEF&&cpu->hl==0xD234,
          "resident byte product low result and preserved DE/HL/C",left*256+right);
  cpu->a=left;cpu->bc=0xA500|right;cpu->de=0xBEEF;call(c,0x22E);
  require(cpu->hl==left*right&&cpu->a==left&&cpu->bc==right&&cpu->de==left,
          "resident byte product wide result and rotated C restore",left*256+right);
  cpu->a=left;cpu->bc=0xA500|right;cpu->de=0xBEEF;call(c,0x234);
  unsigned quotient=right?left/right:255,remainder=right?left%right:left;
  require(cpu->hl==((remainder<<8)|quotient)&&cpu->bc==right&&cpu->de==0xBEEF,
          "resident byte division full domain including zero divisor",left*256+right);
 }
 for(unsigned value=0;value<65536;value++){
  cpu->de=value;cpu->bc=0xFFFF;call(c,0x231);
  require(cpu->hl==((value*65535u)&65535)&&cpu->de==0&&cpu->bc==0xFFFF&&cpu->a==0,
          "resident word product low result full DE domain",value);
 }
 const unsigned fullDivisors[]={0,100,255};
 for(unsigned n=0;n<3;n++)for(unsigned value=0;value<65536;value++){
  unsigned divisor=fullDivisors[n],expected=modelWordDivision(value,divisor);
  cpu->hl=value;cpu->bc=0xA500|divisor;cpu->de=0xBEEF;call(c,0x237);
  require(cpu->hl==expected&&cpu->bc==divisor&&cpu->d==0xBE&&cpu->e==(expected>>8),
          "resident word division literal8bit remainder full value domain",divisor*65536+value);
 }
 const unsigned values[]={0,1,9,10,99,100,101,255,256,999,1000,9999,10000,25599,25600,25601,65534,65535};
 for(unsigned left=0;left<18;left++)for(unsigned right=0;right<18;right++){
  unsigned de=values[left],bc=values[right];cpu->de=de;cpu->bc=bc;call(c,0x231);
  require(cpu->hl==((de*bc)&65535)&&cpu->de==0&&cpu->bc==bc&&cpu->a==0,
          "resident word product representative BC/DE pairs",left*18+right);
 }
 const unsigned divisors[]={1,2,10,127,128,129,254};
 for(unsigned d=0;d<7;d++)for(unsigned n=0;n<18;n++){
  unsigned divisor=divisors[d],value=values[n],expected=modelWordDivision(value,divisor);
  cpu->hl=value;cpu->bc=0xA500|divisor;cpu->de=0xBEEF;call(c,0x237);
  require(cpu->hl==expected&&cpu->bc==divisor&&cpu->d==0xBE&&cpu->e==(expected>>8),
          "resident word division other divisor boundaries",divisor*65536+value);
 }
 }
 { /* Queued tile-text: isolated state paths, never unknown rendering callees. */
 const unsigned pointers[]={0,0xC655,0xD800,0xFFFF};
 for(unsigned n=0;n<4;n++){
  wr(c,0xC1AA,0xA5);wr(c,0xC1AD,0x5A);wr(c,0xC1B3,0xA5);wr(c,0xC1B4,0x5A);wr(c,0xC1B8,4);
  cpu->hl=pointers[n];cpu->bc=0xBEEF;call(c,0x1E9);
  require(rd(c,0xC1AB)==(pointers[n]&255)&&rd(c,0xC1AC)==(pointers[n]>>8)&&
   rd(c,0xC1AA)==0xA5&&rd(c,0xC1AD)==0x5A&&rd(c,0xC1B3)==0&&rd(c,0xC1B4)==0&&
   rd(c,0xC1B8)==1&&cpu->hl==0xC1B8&&cpu->de==1&&cpu->bc==0xBEEF,
   "queued pointer setter preserves guards and initializes state",n);
 }
 for(unsigned index=0;index<256;index++){
  unsigned address=0x27CB+((index*2)&255),target=rd(c,address)|(rd(c,address+1)<<8);
  wr(c,0xC1B8,index);wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x1EC;
  unsigned steps=0;while(cpu->pc!=0x600&&steps++<100)c->step(c);
  require(cpu->pc==0x600&&cpu->hl==target&&cpu->de==target&&cpu->sp==0xCFFE,
   "queued dispatch doubled8bit index stops before unknown target",index);
 }
 for(unsigned state=0;state<=3;state++){
  if(state==1)continue;
  wr(c,0xC1B8,state);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xC655,0);wr(c,0xC1B9,0);
  wr(c,0xC1B4,0xA5);call(c,0x1EC);
  require(rd(c,0xC1B8)==0&&rd(c,0xC1B4)==0xA5&&rd(c,0xC1AB)==0x55&&rd(c,0xC1AC)==0xC6,
   "queued known no-op clear and terminated paths complete through dispatcher",state);
 }
 const unsigned delays[]={0,1,2,255};
 for(unsigned n=0;n<4;n++)for(unsigned pressed=0;pressed<2;pressed++)for(unsigned count=0;count<256;count++){
  unsigned delay=delays[n],next=(count+1)&255;
  bool render=delay==0||pressed||next==(delay==1?4:10);unsigned target=render?0x2805:0x281E;
  wr(c,0xC1BA,delay);wr(c,0xC1BB,count);wr(c,0xFF96,pressed);wr(c,0xFFFF,0);wr(c,0xFF0F,0);
  struct GB *g=c->board;g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->sp=0xCFFE;cpu->pc=0x27D6;unsigned steps=0;while(cpu->pc!=target&&steps++<100)c->step(c);
  require(cpu->pc==target&&cpu->sp==0xCFFE&&rd(c,0xC1BB)==(render?0:next),
   "queued delay prefix stops before renderer or joypad poll",n*512+pressed*256+count);
 }
 for(unsigned mask=0;mask<256;mask++){
  wr(c,0xFF97,mask);wr(c,0xC1B8,4);wr(c,0xC1B4,0xA5);call(c,0x28AF);
  require(rd(c,0xC1B8)==((mask&1)?1:4)&&rd(c,0xC1B4)==((mask&1)?0:0xA5)&&rd(c,0xFF97)==mask,
   "queued state4 independent tail uses input bit0",mask);
 }
 for(unsigned mode=0;mode<3;mode++){
  wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xC655,mode==0?1:0);wr(c,0xC1B9,mode==0?0:mode);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x287B;
  unsigned steps=0;while(cpu->pc!=0x2892&&steps++<100)c->step(c);
  require(cpu->pc==0x2892&&cpu->hl==0xC655&&cpu->sp==0xCFFE,
   "queued state2 nonterminating prefix stops before renderer",mode);
 }
 for(unsigned mask=0;mask<256;mask++){
  wr(c,0xFF97,mask);wr(c,0xC1B8,2);wr(c,0xC1B4,0xA5);
  if(!(mask&1)){
   call(c,0x2895);require(rd(c,0xC1B8)==2&&rd(c,0xC1B4)==0xA5,
    "queued state2 independent no-input tail returns",mask);
  }else{
   wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
   cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x2895;
   unsigned steps=0;while(cpu->pc!=0x289A&&steps++<100)c->step(c);
   require(cpu->pc==0x289A&&cpu->sp==0xCFFE&&rd(c,0xC1B8)==2,
    "queued state2 input tail stops before unknown helper",mask);
  }
 }
 wr(c,0xC1B8,2);wr(c,0xC1B4,0xA5);call(c,0x289D);
 require(rd(c,0xC1B8)==1&&rd(c,0xC1B4)==0,"queued state2 final independent tail resets state",0);
 wr(c,0xC1BA,0);wr(c,0xC1B3,3);call(c,0x2808);
 require(rd(c,0xC1B3)==0,"queued state1 independent four-count tail returns",0);
 }
 { /* Queued text consumer: literal controls and display-record producer. */
 for(unsigned count=0;count<256;count++){
  for(unsigned i=0;i<66;i++)wr(c,0xC1C9+i,0xA5);
  wr(c,0xC1C4,count);cpu->de=0x1234;cpu->bc=0x5678;call(c,0x118F);
  bool exact=rd(c,0xC1C4)==(count<16?count+1:count)&&cpu->de==0x1234&&cpu->bc==0x5678;
  for(unsigned i=0;i<66;i++){
   unsigned value=0xA5;
   if(count<16&&i>=1+count*4&&i<5+count*4){const unsigned record[]={0x34,0x12,0x78,0x56};value=record[i-1-count*4];}
   exact&=rd(c,0xC1C9+i)==value;
  }
  require(exact,"display record all count bytes capacity16 exact four-byte writes",count);
 }
 const unsigned values[]={0,1,15,16,31,127,128,255};
 for(unsigned x=0;x<8;x++)for(unsigned y=0;y<8;y++)for(unsigned w=0;w<8;w++)for(unsigned h=0;h<8;h++){
  unsigned low=values[x],high=values[y],width=values[w],height=values[h];
  unsigned e=(8+8*((low+width+1)&31))&255;
  unsigned d=(8+4*((((low>>4)&14)|((high<<4)&48))+4*(height+1)))&255;
  wr(c,0xC1A5,low);wr(c,0xC1A6,high);wr(c,0xC1A8,width);wr(c,0xC1A9,height);
  cpu->bc=0xBEEF;call(c,0x20A);
  require(cpu->de==((d<<8)|e)&&cpu->hl==0xC1A6&&cpu->bc==0xBEEF,
   "text cursor literal packed coordinates retain byte wrap",x*512+y*64+w*8+h);
 }
 wr(c,0xC1A5,31);wr(c,0xC1A6,255);wr(c,0xC1A8,128);wr(c,0xC1A9,255);
 for(unsigned phase=0;phase<256;phase++)for(unsigned full=0;full<2;full++){
  wr(c,0xFF8B,phase);wr(c,0xC1C4,full?16:0);
  for(unsigned i=0;i<4;i++)wr(c,0xC1CA+i,0xA5);
  call(c,0x207);
  require(rd(c,0xC1C4)==(full?16:1)&&rd(c,0xC1CA)==(full?0xA5:8)&&
   rd(c,0xC1CB)==(full?0xA5:200)&&rd(c,0xC1CC)==(full?0xA5:255)&&
   rd(c,0xC1CD)==(full?0xA5:0x7E +((phase>>3)&1)),
   "cursor display wrapper blink bit3 and full queue",phase*2+full);
 }
 for(unsigned remaining=0;remaining<256;remaining++){
  wr(c,0xC655,0);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xC1AD,0x00);wr(c,0xC1AE,0xD8);
  wr(c,0xC1B9,remaining);wr(c,0xC1B8,1);wr(c,0xC1BE,0xA5);call(c,0x20D);
  unsigned pointer=rd(c,0xC1AB)|(rd(c,0xC1AC)<<8);
  require(pointer==(remaining?0xD800:0xC656)&&rd(c,0xC1B9)==(remaining?remaining-1:0)&&
   rd(c,0xC1B8)==(remaining?1:3)&&rd(c,0xC1BE)==0,
   "text zero control complete repeat restore or state3",remaining);
 }
 for(unsigned value=0;value<256;value++){
  wr(c,0xC655,2);wr(c,0xC656,value);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xC1B8,1);
  wr(c,0xC1BF,0xA5);call(c,0x20D);
  require(rd(c,0xC1BF)==value&&rd(c,0xC1AB)==0x57&&rd(c,0xC1AC)==0xC6&&rd(c,0xC1B8)==1,
   "text control2 consumes one raw operand",value);
 }
 for(unsigned operand=0;operand<256;operand++)for(unsigned callback=0;callback<2;callback++){
  wr(c,0xC655,3);wr(c,0xC656,operand);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xC1B9,operand);
  wr(c,0xC1C0,callback?0xD5:0);wr(c,0xC1C1,callback?0x27:0);wr(c,0xC1B8,1);call(c,0x20D);
  require(rd(c,0xFF9D)==operand&&rd(c,0xC1AB)==0x57&&rd(c,0xC1AC)==0xC6&&
   rd(c,0xC1AD)==0x57&&rd(c,0xC1AE)==0xC6&&rd(c,0xC1B9)==((operand+1)&255)&&
   rd(c,0xC1B8)==1&&(!callback||cpu->a==operand),
   "text control3 repeat pointer and optional original RET callback",operand*2+callback);
 }
 const unsigned widths[]={0,1,2,16,255},rows[]={0,1,254,255},heights[]={0,1,127,128,255};
 for(unsigned col=0;col<256;col++)for(unsigned w=0;w<5;w++)for(unsigned row=0;row<4;row++)for(unsigned h=0;h<5;h++){
  unsigned next=(col+1)&255,newRow=rows[row],state=1;
  if(col>=((widths[w]-1)&255)&&next){next=0;newRow=(newRow+2)&255;if(newRow==((heights[h]*2)&255)){newRow=0;state=2;}}
  wr(c,0xC1BC,col);wr(c,0xC1BD,rows[row]);wr(c,0xC1A8,widths[w]);wr(c,0xC1A9,heights[h]);wr(c,0xC1B8,1);
  call(c,0x210);
  require(rd(c,0xC1BC)==next&&rd(c,0xC1BD)==newRow&&rd(c,0xC1B8)==state,
   "text column progression fallthrough newline literal wrap and equality",col*100+w*20+row*5+h);
 }
 for(unsigned col=0;col<256;col++)for(unsigned row=0;row<4;row++)for(unsigned h=0;h<5;h++){
  unsigned newRow=col?(rows[row]+2)&255:rows[row],state=1;
  if(col&&newRow==((heights[h]*2)&255)){newRow=0;state=2;}
  wr(c,0xC655,1);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);
  wr(c,0xC1BC,col);wr(c,0xC1BD,rows[row]);wr(c,0xC1A9,heights[h]);wr(c,0xC1B8,1);call(c,0x20D);
  require(rd(c,0xC1BC)==0&&rd(c,0xC1BD)==newRow&&rd(c,0xC1B8)==state&&rd(c,0xC1AB)==0x56,
   "text control1 complete newline no-op for zero column",col*20+row*5+h);
 }
 for(unsigned value=0;value<256;value++)for(unsigned n=0;n<8;n++){
  if(value==0||value==1||value==2||value==3||value==4||value==15)continue;
  wr(c,0xC655,value);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xC1BC,values[n]);wr(c,0xC1BD,values[7-n]);
  wr(c,0xC1A4,255);wr(c,0xC1A7,128);wr(c,0xC1B8,1);wr(c,0xC1BE,0xA5);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x2E15;
  unsigned steps=0;while(cpu->pc!=0x2EDB&&steps++<200)c->step(c);
  require(cpu->pc==0x2EDB&&cpu->sp==0xCFFE&&cpu->a==value&&rd(c,0xFF9D)==value&&
   cpu->b==((values[n]+255)&255)&&cpu->c==((values[7-n]+128-(value>=254))&255)&&
   rd(c,0xC1BE)==(value>=254)&&rd(c,0xC1AB)==0x56&&rd(c,0xC1B8)==1,
   "text ordinary byte prefix stops before glyph renderer",value*8+n);
 }
 wr(c,0xC655,15);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xC1B8,1);call(c,0x20D);
 require(rd(c,0xC1B8)==4&&rd(c,0xC1AB)==0x56,"text control0F state4",0);
 wr(c,0xC655,4);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xFFFF,0);wr(c,0xFF0F,0);
 struct GB *g=c->board;g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x2E15;
 unsigned steps=0;while(cpu->pc!=0x2EAB&&steps++<100)c->step(c);
 require(cpu->pc==0x2EAB&&cpu->sp==0xCFFE&&rd(c,0xC1AB)==0x56,"text control4 stops before helper2D53",0);
 for(unsigned input=0;input<256;input++){
  wr(c,0xC1B8,4);wr(c,0xC1B4,0xA5);wr(c,0xFF97,input);wr(c,0xC1C4,0);call(c,0x1EC);
  require(rd(c,0xC1C4)==1&&rd(c,0xC1B8)==((input&1)?1:4)&&rd(c,0xC1B4)==((input&1)?0:0xA5),
   "queued state4 now complete with actual cursor queue producer",input);
 }
 wr(c,0xC655,0);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xC1B9,0);wr(c,0xC1BA,0);
 wr(c,0xC1B8,1);wr(c,0xC1B3,3);call(c,0x1EC);
 require(rd(c,0xC1B8)==3&&rd(c,0xC1B3)==0&&rd(c,0xC1AB)==0x56,
  "queued state1 terminator complete four-count return",0);
 }
 { /* Glyph renderer: prefix arithmetic, row-offset indexing and LCD-on CPU cases. */
 wr(c,0xFF40,0);
 for(unsigned row=0;row<256;row++)for(unsigned col=0;col<256;col++){
  unsigned p=0x2FF1+((row*2)&255),offset=rd(c,p)|(rd(c,p+1)<<8);
  cpu->bc=(col<<8)|row;call(c,0x2FE0);
  require(cpu->hl==((offset+col)&65535)&&cpu->de==offset&&cpu->bc==((col<<8)|row),
   "glyph tilemap offset doubled8bit row and full column domain",row*256+col);
 }
 for(unsigned glyph=0;glyph<256;glyph++)for(unsigned count=0;count<256;count++){
  wr(c,0xFF4F,count&1);wr(c,0xC1AF,glyph&1);wr(c,0xC1C2,count);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->a=glyph;cpu->bc=0x0302;cpu->pc=0x2F1C;
  unsigned steps=0;while(cpu->pc!=0x2F6B&&steps++<300)c->step(c);
  unsigned src=0x3F00+16*glyph,dst=(0x96B0-16*count)&65535;
  require(cpu->pc==0x2F6B&&cpu->sp==0xCFFC&&cpu->bc==0x0302&&cpu->de==dst&&
   rd(c,0xFF51)==(src>>8)&&rd(c,0xFF52)==(src&0xF0)&&
   rd(c,0xFF53)==(dst>>8)&&rd(c,0xFF54)==(dst&0xF0)&&
   rd(c,0xC1C3)==((0x6B-count)&255)&&rd(c,0xC113)==2&&rd(c,0xC114)==0&&
   (rd(c,0xFF4F)&1)==(glyph&1)&&!g->memory.ime,
   "glyph prefix all indices and counters stops before tilemap/HDMA trigger",glyph*256+count);
 }
 const unsigned glyphs[]={0,15,16,127,254,255},counts[]={0,1,106};
 for(unsigned gi=0;gi<6;gi++)for(unsigned ci=0;ci<3;ci++)for(unsigned initial=0;initial<2;initial++){
  unsigned glyph=glyphs[gi],count=counts[ci],src=0x3F00+glyph*16,dst=0x96B0-count*16;
  wr(c,0xFF40,0);wr(c,0x27FF,2);wr(c,0x2800,0);
  unsigned expected[16];for(unsigned i=0;i<16;i++)expected[i]=rd(c,src+i);
  for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,initial);wr(c,0xC1AF,initial);wr(c,0xC1C2,count);wr(c,0xC1BF,1);wr(c,0xC1B1,0x23);
  wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xFFAB,0x14);wr(c,0xFFAC,0);
  wr(c,0x27FF,0x14);wr(c,0x2800,0);
  unsigned restored[8];for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x4000+i);
  wr(c,0xFF40,0x91);
  cpu->a=glyph;cpu->bc=0x0302;call(c,0x216);
  struct GB *g=c->board;
  bool exact=rd(c,0xC1C2)==count+1&&rd(c,0xC1C3)==0x6B-count&&
   rd(c,0xC113)==0x14&&rd(c,0xC114)==0&&(rd(c,0xFF4F)&1)==initial&&g->memory.ime&&g->memory.hdmaRemaining==0;
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==restored[i];
  wr(c,0xFF40,0);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned address=0x8000;address<0xA000;address++){
    unsigned value=0xA5;
    if(address==0x9843)value=plane?0x23:0x6B-count;
    if(plane==1&&address>=dst&&address<dst+16)value=expected[address-dst];
    exact&=rd(c,address)==value;
   }
  }
  require(exact,"glyph LCD-on full renderer exact two-plane maps and16byte HDMA",gi*6+ci*2+initial);
 }
 wr(c,0xFF40,0);
 }
 { /* Rectangle fill; zero byte dimensions are wrap counters, not empty. */
 const unsigned widths[]={1,4,32,0},heights[]={1,2,0,128};
 for(unsigned w=0;w<4;w++)for(unsigned h=0;h<4;h++)for(unsigned kind=0;kind<2;kind++)for(unsigned initial=0;initial<2;initial++){
  if(w==3&&h>=2)continue; /* Would extend beyond VRAM; not executed. */
  unsigned width=widths[w]?widths[w]:256,rows=(heights[h]*2)&255;if(!rows)rows=256;
  unsigned base=h>=2?0x8000:0x9800,tile=kind?0x70:0x79;
  wr(c,0xFF40,0);
  for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,initial);wr(c,0xC1AA,kind);wr(c,0xC1A4,0);wr(c,0xC1A7,1);
  wr(c,0xC1B5,base&255);wr(c,0xC1B6,base>>8);wr(c,0xC1A8,widths[w]);wr(c,0xC1A9,heights[h]);
  wr(c,0xC1A3,0x23);wr(c,0xC1BC,0xA5);wr(c,0xC1BD,0x5A);callWithLimit(c,0x201,2000000);
  bool exact=rd(c,0xC1BC)==0&&rd(c,0xC1BD)==0&&rd(c,0xC1C3)==tile&&
   (rd(c,0xFF4F)&1)==initial&&cpu->hl==base+32*rows&&cpu->bc==(widths[w]<<8);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned address=0x8000;address<0xA000;address++){
    bool filled=false;
    for(unsigned row=0;row<rows;row++)if(address>=base+row*32&&address<base+row*32+width)filled=true;
    exact&=rd(c,address)==(filled?(plane?0x23:tile):0xA5);
   }
  }
  require(exact,"text rectangle LCD-off exact planes zero-width and doubled-height wrap",w*16+h*4+kind*2+initial);
 }
 for(unsigned lcd=0;lcd<2;lcd++)for(unsigned entry=0;entry<3;entry++)for(unsigned kind=0;kind<3;kind++)for(unsigned initial=0;initial<2;initial++){
  wr(c,0xFF40,0);
  for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,initial);wr(c,0xC1AA,kind==2?255:kind);wr(c,0xC1A4,3);wr(c,0xC1A7,3);
  wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1A8,4);wr(c,0xC1A9,2);wr(c,0xC1A3,0x23);
  wr(c,0xC1B8,2);wr(c,0xC1B4,0xA5);wr(c,0xC1C4,16);wr(c,0xFF97,1);
  wr(c,0xC655,entry==1?4:1);wr(c,0xC1AB,0x55);wr(c,0xC1AC,0xC6);wr(c,0xC1B9,0);
  wr(c,0xC1BC,0xA5);wr(c,0xC1BD,0x5A);if(lcd)wr(c,0xFF40,0x91);
  call(c,entry==0?0x201:entry==1?0x20D:0x1EC);
  bool exact=(rd(c,0xFF4F)&1)==initial&&rd(c,0xC1BC)==0&&rd(c,0xC1BD)==0&&
   rd(c,0xC1B8)==(entry==2?1:2)&&rd(c,0xC1B4)==(entry==2?0:0xA5)&&
   (entry!=1||rd(c,0xC1AB)==0x56);
  wr(c,0xFF40,0);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned address=0x8000;address<0xA000;address++){
    bool filled=address>=0x9843&&address<0x9843+4*32&&((address-0x9843)%32)<4;
    exact&=rd(c,address)==(filled?(plane?0x23:kind==1?0x70:0x79):0xA5);
   }
  }
  require(exact,"text fill complete direct control4 and state2 LCD-off/on guards",lcd*18+entry*6+kind*2+initial);
 }
 wr(c,0xFF40,0);
 }
 { /* Shadow producer only; no OAM DMA or natural menu launch. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);
 for(unsigned window=0;window<2;window++)for(unsigned count=0;count<=16;count++)for(unsigned pattern=0;pattern<16;pattern++){
  wr(c,0x27FF,4);wr(c,0x2800,0);wr(c,0x37FF,5);wr(c,0x3800,0);
  wr(c,0xFFAB,4);wr(c,0xFFAC,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);
  unsigned savedA[8],savedB[8];for(unsigned i=0;i<8;i++){savedA[i]=rd(c,0x4000+i);savedB[i]=rd(c,0x6000+i);}
  wr(c,0xC21C,window?0x15:0x14);wr(c,0xC21D,0);wr(c,0xC1C5,0);wr(c,0xC1C6,window?0x60:0x40);
  wr(c,0xC1C4,count);wr(c,0xC1B7,pattern*17);wr(c,0xC0A0,0xA5);
  for(unsigned i=0;i<160;i++)wr(c,0xC000+i,0xCC);
  for(unsigned slot=0;slot<count;slot++){
   wr(c,0xC1CA+slot*4,(pattern*17+slot)&255);wr(c,0xC1CB+slot*4,(255-pattern*17-slot)&255);
   wr(c,0xC1CC+slot*4,255);wr(c,0xC1CD+slot*4,(slot*19+pattern)&255);
  }
  call(c,0x261);
  bool exact=rd(c,0xC1C4)==0&&rd(c,0xC0A0)==0xA5;
  for(unsigned i=0;i<160;i++){
   unsigned slot=i/4,value=0;
   if(slot<count){const unsigned record[]={((255-pattern*17-slot)&255),((pattern*17+slot)&255),((slot*19+pattern)&255),pattern*17};value=record[i%4];}
   exact&=rd(c,0xC000+i)==value;
  }
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==savedA[i]&&rd(c,0x6000+i)==savedB[i];
  require(exact,"shadow direct records0..16 exact order clear guards A/B restore",window*272+count*16+pattern);
 }
 for(unsigned pieces=0;pieces<256;pieces++)for(unsigned pattern=0;pattern<2;pattern++){
  wr(c,0xC1C4,1);wr(c,0xC1C5,0);wr(c,0xC1C6,0xD8);wr(c,0xC21C,0x15);wr(c,0xC21D,0);
  wr(c,0xFFAD,5);wr(c,0xFFAE,0);wr(c,0x37FF,5);wr(c,0x3800,0);
  unsigned restored[8];for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x6000+i);
  wr(c,0xD804,0);wr(c,0xD805,0xD9);wr(c,0xD906,0);wr(c,0xD907,0xDA);
  wr(c,0xDA00,pieces);wr(c,0xC1CA,pattern?255:0);wr(c,0xC1CB,pattern?128:1);
  wr(c,0xC1CC,2);wr(c,0xC1CD,3);wr(c,0xC0A0,0xA5);
  for(unsigned slot=0;slot<pieces;slot++){
   wr(c,0xDA01+slot*4,(slot*7)&255);wr(c,0xDA02+slot*4,(255-slot*9)&255);
   wr(c,0xDA03+slot*4,slot);wr(c,0xDA04+slot*4,(slot*3)&255);
  }
  call(c,0x261);
  unsigned emitted=pieces<40?pieces:40;
  bool exact=rd(c,0xC1C4)==0&&rd(c,0xC1C7)==40-emitted&&rd(c,0xC0A0)==0xA5;
  for(unsigned i=0;i<160;i++){
   unsigned slot=i/4,value=0;
   if(slot<emitted){const unsigned record[]={((pattern?128:1)+slot*7)&255,((pattern?255:0)+255-slot*9)&255,slot,(slot*3)&255};value=record[i%4];}
   exact&=rd(c,0xC000+i)==value;
  }
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x6000+i)==restored[i];
  require(exact,"shadow expanded object all count bytes capacity40 raw offset wrap",pieces*2+pattern);
 }
 /* Artificial expanded40 then direct: inspect the branch before stack pops. */
 wr(c,0xC1C4,2);wr(c,0xDA00,40);wr(c,0xC1CE,1);wr(c,0xC1CF,2);wr(c,0xC1D0,255);wr(c,0xC1D1,0x7E);
 wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
 cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x11AA;
 unsigned steps=0;while(cpu->pc!=0x122A&&steps++<100000)c->step(c);
 require(cpu->pc==0x122A&&rd(c,0xC1C7)==0&&cpu->sp==0xCFF8&&rd(c,0xC0A0)==0xA5,
  "shadow artificial capacity40 then direct stops before unmatched AF pop path",0);
 }
 { /* Original A0F two-variant display objects; bounded forced expansion. */
 const unsigned pointers[]={0,0x5288,0xD800,0xFFFF};
 for(unsigned n=0;n<4;n++){
  wr(c,0xC1C4,0xA5);wr(c,0xC1C7,0x5A);cpu->hl=pointers[n];cpu->bc=0xBEEF;cpu->de=0x1234;call(c,0x258);
  require(rd(c,0xC1C5)==(pointers[n]&255)&&rd(c,0xC1C6)==(pointers[n]>>8)&&
   rd(c,0xC1C4)==0xA5&&rd(c,0xC1C7)==0x5A&&cpu->hl==pointers[n]&&cpu->bc==0xBEEF&&cpu->de==0x1234,
   "display pointer setter preserves registers and guards",n);
 }
 wr(c,0xFF40,0);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
 cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x409C;
 unsigned steps=0;while(cpu->pc!=0x40B2&&steps++<100)c->step(c);
 require(cpu->pc==0x40B2&&cpu->sp==0xCFFE&&rd(c,0xC21C)==0x0F&&rd(c,0xC21D)==0&&
  rd(c,0xC1C5)==0x88&&rd(c,0xC1C6)==0x52&&(rd(c,0xFF4F)&1)==0&&!g->memory.ime,
  "A0F actual setup prefix stops before callback installation",0);
 const unsigned objectPointers[]={0x52A2,0x52C3},pieceCounts[]={8,10};
 unsigned records[2][40];
 require((rd(c,0x5288)|(rd(c,0x5289)<<8))==0x529E&&
  (rd(c,0x529E)|(rd(c,0x529F)<<8))==objectPointers[0]&&
  (rd(c,0x52A0)|(rd(c,0x52A1)<<8))==objectPointers[1],"A0F actual two-level pointer prefix",0);
 for(unsigned variant=0;variant<2;variant++){
  require(rd(c,objectPointers[variant])==pieceCounts[variant],"A0F actual object count measured extent",variant);
  for(unsigned i=0;i<pieceCounts[variant]*4;i++)records[variant][i]=rd(c,objectPointers[variant]+1+i);
 }
 for(unsigned variant=0;variant<2;variant++)for(unsigned x=0;x<256;x++)for(unsigned y=0;y<256;y++){
  wr(c,0xC1CA,x);wr(c,0xC1CB,y);wr(c,0xC1CC,0);wr(c,0xC1CD,variant);wr(c,0xC1C4,1);
  wr(c,0xC1C5,0x88);wr(c,0xC1C6,0x52);wr(c,0xC21C,0x0F);wr(c,0xC21D,0);
  wr(c,0xFFAB,4);wr(c,0xFFAC,0);wr(c,0x27FF,4);wr(c,0x2800,0);wr(c,0xC0A0,0xA5);
  unsigned restored[8];for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x4000+i);call(c,0x261);
  bool exact=rd(c,0xC1C4)==0&&rd(c,0xC1C7)==40-pieceCounts[variant]&&rd(c,0xC0A0)==0xA5&&rd(c,0xC113)==4&&rd(c,0xC114)==0;
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==restored[i];
  for(unsigned i=0;i<160;i++){
   unsigned slot=i/4,value=0;
   if(slot<pieceCounts[variant]){
    value=records[variant][i];if(i%4==0)value=(value+y)&255;if(i%4==1)value=(value+x)&255;
   }
   exact&=rd(c,0xC000+i)==value;
  }
  require(exact,"A0F original objects both variants full XY byte domains",variant*65536+x*256+y);
 }
 }
 { /* A0F variant->position->original object->shadow, forced full byte domain. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 const unsigned objectPointers[]={0x52A2,0x52C3},pieceCounts[]={8,10};unsigned records[2][40];
 for(unsigned variant=0;variant<2;variant++)for(unsigned i=0;i<pieceCounts[variant]*4;i++)records[variant][i]=rd(c,objectPointers[variant]+1+i);
 wr(c,0xC21C,0x0F);wr(c,0xC21D,0);cpu->hl=0x5288;call(c,0x258);
 wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);
 for(unsigned col=0;col<256;col++)for(unsigned row=0;row<256;row++){
  unsigned adjusted=col;if(adjusted>=5)adjusted=(adjusted+1)&255;if(adjusted>=11)adjusted=(adjusted+1)&255;
  unsigned x=((((adjusted<<3)|(adjusted>>5))&255)+0x10)&255;
  unsigned y=((((row<<4)|(row>>4))&255)+0x50)&255,variant=row<4?0:1;
  wr(c,0xC766,col);wr(c,0xC767,row);wr(c,0xC76B,0xA5);wr(c,0xC1C4,0);
  call(c,0x4306);require(rd(c,0xC76B)==variant&&rd(c,0xC766)==col&&rd(c,0xC767)==row,
   "A0F selector all row bytes threshold4",col*256+row);
  call(c,0x438A);
  require(rd(c,0xC768)==x&&rd(c,0xC769)==y&&rd(c,0xC1C4)==1&&
   rd(c,0xC1CA)==x&&rd(c,0xC1CB)==y&&rd(c,0xC1CC)==0&&rd(c,0xC1CD)==variant,
   "A0F position literal comparisons rotation wrap and queued tableindex0",col*256+row);
  wr(c,0xC0A0,0xA5);call(c,0x261);
  bool exact=rd(c,0xC1C4)==0&&rd(c,0xC1C7)==40-pieceCounts[variant]&&rd(c,0xC0A0)==0xA5&&rd(c,0xC113)==0x0F&&rd(c,0xC114)==0;
  for(unsigned i=0;i<160;i++){
   unsigned value=0;
   if(i/4<pieceCounts[variant]){value=records[variant][i];if(i%4==0)value=(value+y)&255;if(i%4==1)value=(value+x)&255;}
   exact&=rd(c,0xC000+i)==value;
  }
  require(exact,"A0F full selector producer ROM-object shadow chain",col*256+row);
 }
 const unsigned counts[]={0,15,16,255};
 for(unsigned n=0;n<4;n++){
  for(unsigned i=0;i<66;i++)wr(c,0xC1C9+i,0xA5);
  wr(c,0xC1C4,counts[n]);wr(c,0xC766,255);wr(c,0xC767,255);wr(c,0xC76B,1);call(c,0x438A);
  bool exact=rd(c,0xC768)==0x10&&rd(c,0xC769)==0x4F&&rd(c,0xC1C4)==(counts[n]<16?counts[n]+1:counts[n]);
  for(unsigned i=0;i<66;i++){
   unsigned value=0xA5;
   if(counts[n]<16&&i>=1+counts[n]*4&&i<5+counts[n]*4){const unsigned record[]={0x10,0x4F,0,1};value=record[i-1-counts[n]*4];}
   exact&=rd(c,0xC1C9+i)==value;
  }
  require(exact,"A0F producer updates fields even when queue full and preserves guards",n);
 }
 }
 { /* A0F display setup prefix and callback cleanup; no44AE resource call. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 for(unsigned mode=0;mode<256;mode++)for(unsigned initial=0;initial<2;initial++){
  wr(c,0xFF4F,initial);wr(c,0xFF70,initial?7:3);wr(c,0xC765,mode);wr(c,0xC764,0xA5);wr(c,0xC779,0x5A);
  for(unsigned i=0;i<19;i++)wr(c,0xC766+i,0xCC);
  for(unsigned i=0;i<6;i++)wr(c,0xC67F+i,0xA5+i);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);struct GB *g=c->board;g->memory.ime=false;
  cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;cpu->pc=0x409C;
  unsigned steps=0;while(cpu->pc!=0x4134&&steps++<2000)c->step(c);
  bool exact=cpu->pc==0x4134&&cpu->sp==0xCFFE&&cpu->hl==(mode?0x52EC:0x4E20)&&
   rd(c,0xC765)==mode&&rd(c,0xC764)==0xA5&&rd(c,0xC779)==0x5A&&
   rd(c,0xC1C5)==0x88&&rd(c,0xC1C6)==0x52&&rd(c,0xC21C)==0x0F&&rd(c,0xC21D)==0&&
   (rd(c,0xFF4F)&1)==0&&g->memory.wramCurrentBank==1&&g->memory.ime&&
   rd(c,0xFF8E)==0xCE&&rd(c,0xFF8F)==0x47&&rd(c,0xFF92)==0&&rd(c,0xFF93)==0&&
   rd(c,0xC67F)==0xC3&&rd(c,0xC680)==0xCD&&rd(c,0xC681)==0x47&&
   rd(c,0xC682)==0xD9&&rd(c,0xC683)==0xA9&&rd(c,0xC684)==0xAA;
  for(unsigned i=0;i<19;i++){
   unsigned value=0,address=0xC766+i;
   if(address==0xC76A)value=mode?2:0;
   if(address==0xC76E)value=mode?0:4;
   if(address==0xC76F)value=mode?0x10:8;
   if(address==0xC772)value=1;
   if(address==0xC773)value=mode?0xEC:0x20;
   if(address==0xC774)value=mode?0x52:0x4E;
   if(address==0xC775)value=mode?0x98:0x94;
   if(address==0xC776)value=mode?0x99:0x95;
   exact&=rd(c,address)==value;
  }
  require(exact,"A0F complete known setup prefix all mode bytes stops before44AE",mode*2+initial);
 }
 for(unsigned pattern=0;pattern<4;pattern++){
  for(unsigned i=0;i<6;i++)wr(c,0xC67F+i,(pattern*41+i)&255);
  wr(c,0xFF8E,0xA5);wr(c,0xFF8F,0x5A);wr(c,0xFF92,0xA5);wr(c,0xFF93,0x5A);
  call(c,0x4141);
  bool exact=rd(c,0xFF8E)==0&&rd(c,0xFF8F)==0&&rd(c,0xFF92)==0&&rd(c,0xFF93)==0&&
   rd(c,0xC67F)==0xD9&&rd(c,0xC682)==0xD9;
  for(unsigned i=0;i<6;i++)if(i!=0&&i!=3)exact&=rd(c,0xC67F+i)==((pattern*41+i)&255);
  require(exact,"A0F cleanup complete preserves unused empty-stub operands",pattern);
 }
 }
 { /* Count bounded original list format and complete setup/header loading. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 const unsigned values[]={1,0xFD,0xFE,0xFF};
 for(unsigned length=0;length<=16;length++)for(unsigned kind=0;kind<4;kind++){
  for(unsigned i=0;i<length;i++)wr(c,0xC74E +i,values[kind]);wr(c,0xC74E +length,0);
  wr(c,0xC76C,0xA5);wr(c,0xC76D,0x5A);call(c,0x44AE);
  require(rd(c,0xC76C)==length&&rd(c,0xC76D)==(kind>=2?length:0)&&cpu->hl==0xC74E +length,
   "A0F zero-terminated list total and FE/FF counts complete",length*4+kind);
 }
 wr(c,0x37FF,0x5A);wr(c,0x3800,0);unsigned header[12];for(unsigned i=0;i<12;i++)header[i]=rd(c,0x6000+i);
 const unsigned fields[]={0xCF92,0xCF93,0xCF90,0xCF91,0xCF94,0xCF95,0xCF96,0xCF97,0xCF98,0xCF99,0xCF9A,0xCF9B};
 const unsigned modes[]={0,1,128,255},lengths[]={0,1,16};
 for(unsigned m=0;m<4;m++)for(unsigned l=0;l<3;l++)for(unsigned kind=0;kind<4;kind++)for(unsigned prior=0;prior<2;prior++){
  unsigned length=lengths[l],mode=modes[m],oldB=prior?0x15:5;
  for(unsigned i=0;i<length;i++)wr(c,0xC74E +i,values[kind]);wr(c,0xC74E +length,0);wr(c,0xC765,mode);
  wr(c,0x37FF,oldB);wr(c,0x3800,0);wr(c,0xFFAD,oldB);wr(c,0xFFAE,0);
  unsigned restored[8];for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x6000+i);
  call(c,0x409C);
  bool exact=rd(c,0xC76C)==length&&rd(c,0xC76D)==(kind>=2?length:0)&&
   rd(c,0xC76A)==(mode?2:0)&&rd(c,0xC773)==(mode?0xEC:0x20)&&rd(c,0xC774)==(mode?0x52:0x4E)&&
   rd(c,0xC663)==0x5A&&rd(c,0xC664)==0&&rd(c,0xC666)==0x5A&&rd(c,0xC667)==0&&
   rd(c,0xC115)==oldB&&rd(c,0xC116)==0&&cpu->hl==0x600C;
  for(unsigned i=0;i<12;i++)exact&=rd(c,fields[i])==header[i];
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x6000+i)==restored[i];
  require(exact,"A0F complete setup original B5A header list and restored B window",m*24+l*8+kind*2+prior);
 }
 }
 { /* A0F original graphics and tilemap routine; both complete VRAM planes. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 unsigned graphics[1600],maps[2][80],cells[2][2];
 for(unsigned i=0;i<1600;i++)graphics[i]=rd(c,0x47E0+i);
 for(unsigned mode=0;mode<2;mode++){
  for(unsigned i=0;i<80;i++)maps[mode][i]=rd(c,(mode?0x4EB8:0x4E68)+i);
  cells[mode][0]=rd(c,mode?0x4F0A:0x4F08);cells[mode][1]=rd(c,mode?0x4F0B:0x4F09);
 }
 for(unsigned lcd=0;lcd<2;lcd++)for(unsigned mode=0;mode<256;mode++)for(unsigned initial=0;initial<2;initial++){
  if(lcd&&mode!=0&&mode!=1&&mode!=128&&mode!=255)continue;
  wr(c,0xFF40,0);for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);
  }
  wr(c,0xFF4F,initial);wr(c,0xC765,mode);wr(c,0xC21C,0x0F);wr(c,0xC21D,0);
  if(lcd)wr(c,0xFF40,0x91);callWithLimit(c,0x415C,2000000);
  bool exact=(rd(c,0xFF4F)&1)==0&&rd(c,0xC765)==mode&&cpu->a==120;
  wr(c,0xFF40,0);
  for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);
   for(unsigned address=0x8000;address<0xA000;address++){
    unsigned value=0xA5;
    if(plane==initial&&address>=0x8800&&address<0x8E40)value=graphics[address-0x8800];
    if(address>=0x9800&&address<0x9840&&((address-0x9800)%32)<20){
     unsigned offset=(address-0x9800)/32*20+(address-0x9800)%32;value=maps[mode!=0][plane*40+offset];
    }
    if(address>=0x983C&&address<0x98B4)value=cells[mode!=0][plane];
    exact&=rd(c,address)==value;
   }
  }
  require(exact,"A0F complete graphics copy header maps and120 repeated cells both VRAM planes",lcd*512+mode*2+initial);
 }
 wr(c,0xFF40,0);
 }
 { /* Original A0F selection adjustment, every column/row byte pair. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 for(unsigned row=0;row<256;row++)for(unsigned column=0;column<256;column++){
  wr(c,0xC765,0xA5);wr(c,0xC766,column);wr(c,0xC767,0x5A);wr(c,0xC768,0x3C);
  cpu->a=row;cpu->f.packed=(column&15)<<4;unsigned flags=cpu->f.packed;
  call(c,0x431A);
  unsigned snapped=row<4?column:(column<5?1:column<10?6:11);
  require(rd(c,0xC766)==snapped&&rd(c,0xC765)==0xA5&&rd(c,0xC767)==0x5A&&rd(c,0xC768)==0x3C&&
   cpu->a==row&&cpu->f.packed==flags,"A0F incoming row snaps column preserves AF and guards",row*256+column);
  wr(c,0xC766,column);wr(c,0xC767,row);
  call(c,0x433F);
  unsigned remapped=column;
  if(row>=4){
   if(column==0||column==7)remapped=11;
   if(column==2||column==10)remapped=6;
   if(column==5||column==12)remapped=1;
  }
  require(rd(c,0xC766)==remapped&&rd(c,0xC767)==row&&rd(c,0xC765)==0xA5&&rd(c,0xC768)==0x3C,
   "A0F last row six exact column remaps full byte domains",row*256+column);
 }
 }
 { /* Original packed colors and fixed-point components; forced WRAM input. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);
 for(unsigned inverse=0;inverse<2;inverse++)for(unsigned word=0;word<65536;word++){
  wr(c,0xD000,word);wr(c,0xD001,word>>8);wr(c,0xC5FF,0xA5);wr(c,0xC606,0x5A);
  cpu->hl=0xD000;cpu->de=0xC600;cpu->c=1;call(c,inverse?0x925:0x8FB);
  bool exact=cpu->hl==0xD002&&cpu->de==0xC606&&cpu->c==0&&rd(c,0xC5FF)==0xA5&&rd(c,0xC606)==0x5A;
  for(unsigned channel=0;channel<3;channel++){
   unsigned value=(word>>(channel*5))&31;value=inverse?(31-value)*64:value*2048;
   exact&=rd(c,0xC600+channel*2)==(value&255)&&rd(c,0xC601+channel*2)==(value>>8);
  }
  require(exact,"Packed color expansion full16bit input ignores bit15",inverse*65536+word);
 }
 for(unsigned inverse=0;inverse<2;inverse++)for(unsigned count=0;count<256;count++){
  unsigned length=count?count:256;
  for(unsigned i=0;i<length;i++){unsigned word=(i*7919+count*257)&65535;wr(c,0xD000+2*i,word);wr(c,0xD001+2*i,word>>8);}
  wr(c,0xC5FF,0xA5);wr(c,0xC600+6*length,0x5A);
  cpu->hl=0xD000;cpu->de=0xC600;cpu->c=count;call(c,inverse?0x925:0x8FB);
  bool exact=cpu->hl==0xD000+2*length&&cpu->de==0xC600+6*length&&cpu->c==0&&rd(c,0xC5FF)==0xA5&&rd(c,0xC600+6*length)==0x5A;
  for(unsigned i=0;i<length;i++)for(unsigned channel=0;channel<3;channel++){
   unsigned value=(((i*7919+count*257)&65535)>>(channel*5))&31;value=inverse?(31-value)*64:value*2048;
   exact&=rd(c,0xC600+6*i+channel*2)==(value&255)&&rd(c,0xC601+6*i+channel*2)==(value>>8);
  }
  require(exact,"Color expansion count byte zero means256 original do loop",inverse*256+count);
 }
 for(unsigned seed=0;seed<256;seed++){
  for(unsigned i=0;i<384;i++)wr(c,0xD000+i,(seed+i*73)&255);
  wr(c,0xC5FF,0xA5);wr(c,0xC680,0x5A);cpu->hl=0xD001;cpu->de=0xC600;cpu->c=seed;call(c,0x96F);
  bool exact=cpu->hl==0xD181&&cpu->de==0xC680&&cpu->c==0&&rd(c,0xC5FF)==0xA5&&rd(c,0xC680)==0x5A;
  for(unsigned i=0;i<64;i++){
   unsigned red=(seed+(6*i+1)*73)&255,green=(seed+(6*i+3)*73)&255,blue=(seed+(6*i+5)*73)&255;
   unsigned rotated=((green<<2)|(green>>6))&255;
   exact&=rd(c,0xC600+2*i)==((red>>3)|(rotated&224));
   exact&=rd(c,0xC601+2*i)==((rotated&3)|(((blue>>1)|(blue<<7))&124));
  }
  require(exact,"Pack64 color components raw highbyte rotations and fixed count",seed);
 }
 }
 { /* Original color scaler/preparers/tick; no IRQ or visible-palette claim. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 unsigned counts[256],resources[2][64];
 for(unsigned mode=0;mode<256;mode++)counts[mode]=mode==2?32:rd(c,mode<2?0x8F8+2-mode:0x8F2+mode-2);
 for(unsigned source=0;source<2;source++)for(unsigned i=0;i<64;i++){
  unsigned address=(source?0x52EC:0x4E20)+2*i;resources[source][i]=rd(c,address)|(rd(c,address+1)<<8);
 }
 for(unsigned mode=0;mode<256;mode++){
  wr(c,0xC421,0xA5);wr(c,0xC5A3,0x5A);wr(c,0xC5A2,0x3C);
  for(unsigned i=0;i<192;i++){unsigned value=(i*7919+mode*257)&65535;wr(c,0xC422+2*i,value);wr(c,0xC423+2*i,value>>8);}
  cpu->a=mode;callWithLimit(c,0x88D,1000000);
  bool exact=cpu->a==counts[mode]&&rd(c,0xC421)==0xA5&&rd(c,0xC5A3)==0x5A&&rd(c,0xC5A2)==(mode==2?0x3C:mode<2?2-mode:mode-2);
  for(unsigned i=0;i<192;i++){unsigned value=colorScaled((i*7919+mode*257)&65535,mode);exact&=rd(c,0xC422+2*i)==(value&255)&&rd(c,0xC423+2*i)==(value>>8);}
  require(exact,"Original color scaler all parameter bytes actual ROM count reads",mode);
 }
 for(unsigned source=0;source<2;source++)for(unsigned add=0;add<2;add++)for(unsigned mode=0;mode<256;mode++){
  wr(c,0xC2A1,0xA5);wr(c,0xC5A3,0x5A);wr(c,0xC21F,0x78);wr(c,0xC220,0x78);wr(c,0xC221,0xA5);
  cpu->hl=source?0x52EC:0x4E20;cpu->a=mode;callWithLimit(c,add?0x17A:0x177,1000000);
  bool exact=rd(c,add?0xC220:0xC21F)==counts[mode]&&rd(c,add?0xC21F:0xC220)==0x78&&rd(c,0xC221)==0xA5&&rd(c,0xC2A1)==0xA5&&rd(c,0xC5A3)==0x5A;
  for(unsigned i=0;i<192;i++){
   unsigned component=(resources[source][i/3]>>(5*(i%3)))&31;
   unsigned base=add?component*2048:0xF800,delta=colorScaled((31-component)*64,mode);
   exact&=rd(c,0xC2A2+2*i)==(base&255)&&rd(c,0xC2A3+2*i)==(base>>8)&&rd(c,0xC422+2*i)==(delta&255)&&rd(c,0xC423+2*i)==(delta>>8);
  }
  require(exact,"Original transition preparation two overlapping ROM resources all mode bytes",source*512+add*256+mode);
 }
 for(unsigned kind=0;kind<3;kind++)for(unsigned count=0;count<256;count++){
  unsigned sub=kind==0?count:kind==2?0x78:0,add=kind==1?count:kind==2?count:0;
  wr(c,0xC21F,sub);wr(c,0xC220,add);wr(c,0xC221,0xA5);wr(c,0xC5A2,0x5A);
  unsigned expected[192];bool active=add||sub;
  for(unsigned i=0;i<192;i++){
   unsigned value=(i*7919+count*257)&65535,delta=(i*4051+count*17)&65535;
   expected[i]=active?(add?value+delta:value-delta)&65535:value;
   wr(c,0xC2A2+2*i,value);wr(c,0xC2A3+2*i,value>>8);wr(c,0xC422+2*i,delta);wr(c,0xC423+2*i,delta>>8);
  }
  for(unsigned i=0;i<128;i++)wr(c,0xC222+i,0xA5);call(c,0x17D);
  bool exact=rd(c,0xC21F)==(add?sub:sub?sub-1:0)&&rd(c,0xC220)==(add?add-1:0)&&rd(c,0xC221)==(active?1:0xA5)&&rd(c,0xC5A2)==0x5A;
  for(unsigned i=0;i<192;i++){
   unsigned delta=(i*4051+count*17)&65535;
   exact&=rd(c,0xC2A2+2*i)==(expected[i]&255)&&rd(c,0xC2A3+2*i)==(expected[i]>>8)&&rd(c,0xC422+2*i)==(delta&255)&&rd(c,0xC423+2*i)==(delta>>8);
  }
  for(unsigned i=0;i<64;i++){
   unsigned packed=((expected[3*i]>>11)&31)|(((expected[3*i+1]>>11)&31)<<5)|(((expected[3*i+2]>>11)&31)<<10);
   exact&=rd(c,0xC222+2*i)==(active?packed&255:0xA5)&&rd(c,0xC223+2*i)==(active?packed>>8:0xA5);
  }
  require(exact,"Color tick add priority counter decrement 192word wrap and packed output",kind*256+count);
 }
 for(unsigned source=0;source<2;source++)for(unsigned add=0;add<2;add++){
  wr(c,0xC21F,0);wr(c,0xC220,0);cpu->hl=source?0x52EC:0x4E20;cpu->a=4;call(c,add?0x17A:0x177);
  require(rd(c,add?0xC220:0xC21F)==8&&rd(c,add?0xC21F:0xC220)==0,"Color transition mode4 starts eight ticks",source*2+add);
  for(unsigned tick=1;tick<=8;tick++){
   wr(c,0xC221,0);call(c,0x17D);bool exact=rd(c,add?0xC220:0xC21F)==8-tick&&rd(c,0xC221)==1;
   unsigned expected[192];
   for(unsigned i=0;i<192;i++){
    unsigned component=(resources[source][i/3]>>(5*(i%3)))&31,delta=(31-component)*256;
    expected[i]=(add?component*2048+tick*delta:0xF800-tick*delta)&65535;
    exact&=rd(c,0xC2A2+2*i)==(expected[i]&255)&&rd(c,0xC2A3+2*i)==(expected[i]>>8)&&rd(c,0xC422+2*i)==(delta&255)&&rd(c,0xC423+2*i)==(delta>>8);
   }
   for(unsigned i=0;i<64;i++){
    unsigned packed=((expected[3*i]>>11)&31)|(((expected[3*i+1]>>11)&31)<<5)|(((expected[3*i+2]>>11)&31)<<10);
    exact&=rd(c,0xC222+2*i)==(packed&255)&&rd(c,0xC223+2*i)==(packed>>8);
   }
   require(exact,"Original mode4 preparation eight ticks exact accumulators packed colors",source*16+add*8+tick-1);
   unsigned savedA=cpu->a,savedF=cpu->f.packed,savedBC=cpu->bc,savedHL=cpu->hl;
   call(c,0x18C);bool uploaded=rd(c,0xC221)==0&&cpu->a==savedA&&cpu->f.packed==savedF&&cpu->bc==savedBC&&cpu->hl==savedHL;
   for(unsigned i=0;i<64;i++){
    unsigned packed=((expected[3*i]>>11)&31)|(((expected[3*i+1]>>11)&31)<<5)|(((expected[3*i+2]>>11)&31)<<10);
    unsigned index=(2*i)&63;wr(c,i<32?0xFF68:0xFF6A,index);
    uploaded&=rd(c,i<32?0xFF69:0xFF6B)==(packed&255);
    wr(c,i<32?0xFF68:0xFF6A,index+1);uploaded&=rd(c,i<32?0xFF69:0xFF6B)==(packed>>8);
   }
   require(uploaded,"Mode4 original LCDoff palette upload exact BG OBJ bytes and registers",source*16+add*8+tick-1);
  }
 }
 }
 { /* Original A0F input gate and directions; empty synthetic upper stream. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);
 wr(c,0xFFAD,0x15);wr(c,0xFFAE,0);wr(c,0x37FF,0x15);wr(c,0x3800,0);
 wr(c,0xC663,0x14);wr(c,0xC664,0);wr(c,0xCF92,0);wr(c,0xCF93,0xD3);
 for(unsigned i=0;i<8;i++){wr(c,0xD300+2*i,0x10);wr(c,0xD301+2*i,0xD6);}wr(c,0xD610,0);
 wr(c,0xFF97,0);wr(c,0xFF98,0);
 for(unsigned busy=0;busy<256;busy++)for(unsigned state=0;state<256;state++){
  wr(c,0xC1B8,busy);wr(c,0xC772,state);wr(c,0xC220,0xA5);wr(c,0xC766,37);wr(c,0xC767,2);
  wr(c,0xC768,0xA5);wr(c,0xC769,0x5A);wr(c,0xC76B,1);wr(c,0xC1C4,16);wr(c,0xC20A,0x3C);
  call(c,0x41C5);bool active=!busy&&state!=0&&state!=99;
  require(rd(c,0xC1B8)==busy&&rd(c,0xC772)==state&&rd(c,0xC220)==0xA5&&rd(c,0xC766)==37&&rd(c,0xC767)==2&&
   rd(c,0xC768)==(active?0x49:0xA5)&&rd(c,0xC769)==(active?0x70:0x5A)&&rd(c,0xC76B)==1&&rd(c,0xC1C4)==16&&rd(c,0xC20A)==0x3C,
   "A0F input gate full busy/state bytes no buttons queue full",busy*256+state);
 }
 for(unsigned counter=0;counter<256;counter++){
  wr(c,0xC1B8,0);wr(c,0xC772,99);wr(c,0xC220,counter);wr(c,0xC768,0xA5);call(c,0x41C5);
  require(rd(c,0xC772)==(counter?99:0)&&rd(c,0xC220)==counter&&rd(c,0xC768)==0xA5,
   "A0F state99 clears only after add transition counter zero",counter);
 }
 const unsigned boundary[]={0,1,2,3,4,5,7,14,255};
 for(unsigned axis=0;axis<2;axis++)for(unsigned mask=0;mask<16;mask++)for(unsigned value=0;value<256;value++)for(unsigned b=0;b<9;b++){
  unsigned column=axis?boundary[b]:value,row=axis?value:boundary[b],variant=0xA5,held=mask<<4;
  wr(c,0xC766,column);wr(c,0xC767,row);wr(c,0xC76B,variant);wr(c,0xC772,1);wr(c,0xC1B8,0);wr(c,0xC1C4,16);
  wr(c,0xC768,0xA5);wr(c,0xC769,0x5A);wr(c,0xFF98,held);wr(c,0xFF97,0);wr(c,0xCF82,0x5A);
  modelA0FDirections(held,&column,&row,&variant);call(c,0x41C5);
  unsigned adjusted=column;if(adjusted>=5)adjusted=(adjusted+1)&255;if(adjusted>=11)adjusted=(adjusted+1)&255;
  unsigned x=((((adjusted<<3)|(adjusted>>5))&255)+16)&255,y=((((row<<4)|(row>>4))&255)+80)&255;
  require(rd(c,0xC766)==column&&rd(c,0xC767)==row&&rd(c,0xC76B)==variant&&rd(c,0xC768)==x&&rd(c,0xC769)==y&&
   rd(c,0xC772)==1&&rd(c,0xC1C4)==16&&rd(c,0xC20A)==0x3C&&rd(c,0xFF98)==held&&rd(c,0xCF82)==(mask?0:0x5A)&&
   rd(c,0xC113)==0x0F&&rd(c,0xC114)==0,"A0F all direction masks byte axes boundary rows cols original empty stream",axis*36864+mask*2304+value*9+b);
 }
 const unsigned actions[9][2]={{0,0},{3,14},{4,0},{4,1},{4,5},{4,6},{4,7},{4,11},{255,255}};
 for(unsigned pressed=0;pressed<256;pressed++)for(unsigned sample=0;sample<9;sample++)for(unsigned list=0;list<3;list++){
  unsigned row=actions[sample][0],column=actions[sample][1],target=0xC100,state=1,choice=0xA5;
  if(pressed&2)target=0x451F;
  else if(pressed&1){
   if(row<4)target=0x43F0;
   else if(column==1)target=0x455D;
   else if(column>=6){choice=(column&8)>>3;if(!choice||list==2){target=0x47AA;state=99;}}
  }else if(pressed&8){column=11;row=4;}
  else if(pressed&4)target=0x455D;
  wr(c,0xC766,actions[sample][1]);wr(c,0xC767,actions[sample][0]);wr(c,0xC76B,0xA5);
  wr(c,0xC764,0xA5);wr(c,0xC772,1);wr(c,0xCF86,0xA5);wr(c,0xCF87,0x5A);
  wr(c,0xC74E,list?0x10:0);wr(c,0xC74F,list==2?1:0);wr(c,0xC750,0);
  wr(c,0xFF98,0);wr(c,0xFF97,pressed);wr(c,0xFFFF,0);wr(c,0xFF0F,0);
  struct GB *g=c->board;g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
  wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x41F1;
  unsigned steps=0;while(cpu->pc!=0xC100&&cpu->pc!=0x451F&&cpu->pc!=0x43F0&&cpu->pc!=0x455D&&cpu->pc!=0x47AA&&steps++<100000)c->step(c);
  unsigned index=pressed*27+sample*3+list;
  require(cpu->pc==target&&cpu->sp==(target==0xC100?0xD000:0xCFFC),"A0F buttons bounded prefix reaches original callee or returns",index);
  require(rd(c,0xC766)==column&&rd(c,0xC767)==row&&rd(c,0xC764)==choice&&rd(c,0xC772)==state&&
   rd(c,0xC76B)==((!(pressed&3)&&(pressed&8))?1:0xA5)&&rd(c,0xFF97)==pressed&&
   rd(c,0xCF86)==(target==0x47AA?2:0xA5)&&rd(c,0xCF87)==(target==0x47AA?1:0x5A),
   "A0F button precedence bounded list skip10 and countdown prefix fields",index);
 }
 wr(c,0xFF97,0);wr(c,0xFF98,0);
 }
 { /* Original A0F mode resource selector, trim prefix and indicator row. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 const unsigned pointers[]={0x5334,0x537C,0x53C4,0x540C};
 for(unsigned mode=0;mode<256;mode++)for(unsigned input=0;input<256;input++){
  wr(c,0xC764,0xA5);wr(c,0xC765,mode);wr(c,0xC766,0x5A);cpu->a=input;call(c,0x43BF);
  unsigned selected=(mode&1)?2+(input&1):input;
  require(cpu->hl==pointers[selected<3?selected:3]&&cpu->a==selected&&rd(c,0xC765)==mode&&rd(c,0xC764)==0xA5&&rd(c,0xC766)==0x5A,
   "A0F resource selector all mode/input bytes exact pointer fallback",mode*256+input);
 }
 const unsigned previous[]={0,0xFD,0xFE,0xFF},metas[]={0,1,255};
 for(unsigned count=0;count<256;count++)for(unsigned kind=0;kind<4;kind++)for(unsigned meta=0;meta<3;meta++){
  unsigned expected[258];for(unsigned i=0;i<258;i++)wr(c,0xC74D+i,(i*73+count*29)&255);
  if(count)wr(c,0xC74D+count-1,previous[kind]);wr(c,0xC76C,count);wr(c,0xC76D,metas[meta]);
  for(unsigned i=0;i<258;i++)expected[i]=rd(c,0xC74D+i);
  if(count){
   expected[31]=(expected[31]-1)&255;unsigned index=expected[31]+1;expected[index]=0;--index;
   if(expected[index]>=254){expected[index]=0;expected[31]=(expected[31]-1)&255;expected[32]=(expected[32]-1)&255;}
  }
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x451F;
  unsigned steps=0;while(cpu->pc!=0x45A0&&cpu->pc!=0xC100&&steps++<100000)c->step(c);
  unsigned sample=count*12+kind*3+meta;
  require(cpu->pc==(count?0x45A0:0xC100)&&cpu->sp==(count?0xCFFC:0xD000),"A0F trim prefix stops before redraw or returns empty count",sample);
  bool exact=true;for(unsigned i=0;i<258;i++)exact&=rd(c,0xC74D+i)==expected[i];
  require(exact,"A0F trim exact memory includes counter alias and previous FE FF underflow",sample);
 }
 wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);wr(c,0xFFAD,0x15);wr(c,0xFFAE,0);
 wr(c,0xC663,0x14);wr(c,0xC664,0);wr(c,0xCF92,0);wr(c,0xCF93,0xD3);
 for(unsigned i=0;i<8;i++){wr(c,0xD300+2*i,0x10);wr(c,0xD301+2*i,0xD6);}wr(c,0xD610,0);
 for(unsigned pressed=0;pressed<256;pressed++){
  if(!(pressed&2))continue;
  wr(c,0xC1B8,0);wr(c,0xC772,1);wr(c,0xC76C,0);wr(c,0xC76D,pressed);wr(c,0xC74E,0xA5);
  wr(c,0xC766,2);wr(c,0xC767,3);wr(c,0xC76B,0);wr(c,0xC1C4,16);wr(c,0xC20A,0x3C);
  wr(c,0xFF98,0);wr(c,0xFF97,pressed);call(c,0x41C5);
  require(rd(c,0xC76C)==0&&rd(c,0xC76D)==pressed&&rd(c,0xC74E)==0xA5&&rd(c,0xC766)==2&&rd(c,0xC767)==3&&
   rd(c,0xC772)==1&&rd(c,0xC768)==32&&rd(c,0xC769)==128&&rd(c,0xC1C4)==16&&rd(c,0xC20A)==0x3C,
   "A0F complete dispatcher button02 precedence empty trim and queued position",pressed);
 }
 wr(c,0xFF97,0);wr(c,0xFF98,0);
 for(unsigned lcd=0;lcd<2;lcd++)for(unsigned seed=0;seed<256;seed++)for(unsigned initial=0;initial<2;initial++){
  if(lcd&&seed!=0&&seed!=1&&seed!=128&&seed!=255)continue;
  unsigned tile0=seed,tile1=(seed*73+1)&255,attr0=(seed*29+3)&255,attr1=(seed*53+5)&255;
  wr(c,0xFF40,0);for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xC774,0x3C);wr(c,0xC775,tile0);wr(c,0xC776,tile1);wr(c,0xC777,attr0);wr(c,0xC778,attr1);wr(c,0xC779,0x5A);
  wr(c,0xFF4F,initial);if(lcd)wr(c,0xFF40,0x91);call(c,0x4628);
  bool exact=(rd(c,0xFF4F)&1)==0&&rd(c,0xC775)==0x90&&rd(c,0xC776)==0x91&&rd(c,0xC777)==attr0&&rd(c,0xC778)==attr1&&rd(c,0xC774)==0x3C&&rd(c,0xC779)==0x5A;
  wr(c,0xFF40,0);for(unsigned plane=0;plane<2;plane++){
   wr(c,0xFF4F,plane);for(unsigned address=0x8000;address<0xA000;address++){
    unsigned value=0xA5;
    if(address==0x9A02)value=plane?attr0:tile0;if(address==0x9A03)value=plane?attr1:tile1;
    if(address==0x9A08)value=plane?attr0:0x8E;if(address==0x9A09)value=plane?attr1:0x8F;
    if(address==0x9A0E)value=plane?attr0:0x90;if(address==0x9A0F)value=plane?attr1:0x91;
    exact&=rd(c,address)==value;
   }
  }
  require(exact,"A0F three indicator pairs original attributes both full VRAM planes",lcd*512+seed*2+initial);
 }
 wr(c,0xFF40,0);
 }
 { /* Original A0F callbacks/frame wait; explicit synthetic wakes, no IRQ trace. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 for(unsigned a=0;a<256;a++)for(unsigned flags=0;flags<16;flags++){
  cpu->a=a;cpu->f.packed=flags<<4;cpu->bc=0x1234;cpu->de=0x5678;cpu->hl=0x9ABC;wr(c,0xC1B8,0x5A);wr(c,0xFF8A,0x3C);call(c,0x47CD);
  require(cpu->a==a&&cpu->f.packed==flags*16&&cpu->bc==0x1234&&cpu->de==0x5678&&cpu->hl==0x9ABC&&rd(c,0xC1B8)==0x5A&&rd(c,0xFF8A)==0x3C,
   "A0F no-op callback all A flags preserves registers and guarded fields",a*16+flags);
 }
 call(c,0x09EB);bool installed=true;for(unsigned i=0;i<10;i++)installed&=rd(c,0xFF80+i)==rd(c,0x09F9+i);
 require(installed,"A0F callback fixture installs actual original ten-byte HRAM DMA",0);
 for(unsigned dirty=0;dirty<256;dirty++)for(unsigned plane=0;plane<2;plane++){
  for(unsigned i=0;i<160;i++)wr(c,0xC000+i,(i*37+dirty*19)&255);
  for(unsigned i=0;i<128;i++)wr(c,0xC222+i,(i*29+dirty*11)&255);
  for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){wr(c,palette?0xFF6A:0xFF68,i);wr(c,palette?0xFF6B:0xFF69,0x19);}
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC221,dirty);wr(c,0xFF8A,0x3C);cpu->a=dirty;cpu->f.packed=(dirty&15)<<4;cpu->bc=0x1234;cpu->de=0x5678;cpu->hl=0x9ABC;call(c,0x47CE);
  bool exact=rd(c,0xC221)==0&&rd(c,0xFF8A)==0x3C&&cpu->a==0&&cpu->f.packed==(0xC0|((dirty&1)<<4))&&cpu->bc==0x1234&&cpu->de==0x5678&&cpu->hl==0x9ABC&&(rd(c,0xFF4F)&1)==plane;
  for(unsigned i=0;i<160;i++)exact&=rd(c,0xFE00+i)==((i*37+dirty*19)&255);
  for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){
   unsigned index=palette*64+i,value=dirty?((index*29+dirty*11)&255):0x19;
   wr(c,palette?0xFF6A:0xFF68,i);unsigned actual=rd(c,palette?0xFF6B:0xFF69);if(actual!=value)fprintf(stderr,"A0F callback palette dirty=%u palette=%u index=%u actual=%02X expected=%02X\n",dirty,palette,i,actual,value);exact&=actual==value;
  }
  if(!exact)fprintf(stderr,"A0F callback registers AF=%02X%02X BC=%04X DE=%04X HL=%04X dirty=%u flag=%u VBK=%u\n",cpu->a,cpu->f.packed,cpu->bc,cpu->de,cpu->hl,rd(c,0xC221),rd(c,0xFF8A),rd(c,0xFF4F)&1);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)exact&=rd(c,0x8000+i)==0xA5;}
  require(exact,"A0F actual OAM DMA palette callback all dirty bytes LCDoff OAM palettes registers untouched VRAM",dirty*2+plane);
 }
 for(unsigned flag=0;flag<256;flag++){
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  wr(c,0xFF8A,flag);wr(c,0xFF8B,0xA5);cpu->bc=0x1234;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x47D5;
  unsigned steps=0;bool woke=wakeSyntheticHalt(c,false);
  require(woke&&rd(c,0xFF8A)==flag,"Frame wait HALTs even when its flag is already nonzero",flag);
  if(flag==0){for(unsigned i=0;i<128;i++)SM83Tick(cpu);require(cpu->pc>=0x47D7&&cpu->pc<=0x47DC&&cpu->sp==0xCFFE&&rd(c,0xFF8A)==0,
    "Frame wait awakened with flag0 still spins before RET",0);wr(c,0xFF8A,1);}
  steps=0;while((cpu->pc!=0xC100||cpu->executionState!=SM83_CORE_FETCH)&&steps++<1000)SM83Tick(cpu);
  require(cpu->pc==0xC100&&cpu->sp==0xD000&&cpu->a==0&&cpu->f.packed==0x80&&cpu->bc==0x1234&&cpu->de==0x5678&&cpu->hl==0x9ABC&&
   rd(c,0xFF8A)==0&&rd(c,0xFF8B)==0xA5&&!g->memory.ime,"Frame wait clears all nonzero flag bytes and preserves registers after synthetic wake",flag);
 }
 unsigned colors[2][64];for(unsigned source=0;source<2;source++)for(unsigned i=0;i<64;i++)colors[source][i]=rd(c,(source?0x52EC:0x4E20)+2*i)|(rd(c,(source?0x52EC:0x4E20)+2*i+1)<<8);
 for(unsigned source=0;source<2;source++)for(unsigned busy=0;busy<256;busy++)for(unsigned plane=0;plane<2;plane++){
  unsigned pointer=source?0x52EC:0x4E20,release=busy?10:8;
  for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){wr(c,palette?0xFF6A:0xFF68,i);wr(c,palette?0xFF6B:0xFF69,0x19);}
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC773,pointer);wr(c,0xC774,pointer>>8);wr(c,0xC1B8,0x5A);wr(c,0xC21F,0);wr(c,0xC220,0);wr(c,0xC221,0);wr(c,0xCF86,busy);wr(c,0xFF8A,0);wr(c,0xFF8B,0xA5);
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x47AA;
  unsigned steps=0,wakes=0;while((cpu->pc!=0xC100||cpu->executionState!=SM83_CORE_FETCH)&&steps++<200000){if(cpu->pc==0x47D5&&cpu->executionState==SM83_CORE_FETCH){wakes++;
   bool before=wakes<=release&&rd(c,0xC220)==(wakes<8?8-wakes:0)&&rd(c,0xCF86)==busy&&rd(c,0xC1B8)==0;
   if(wakes==release)wr(c,0xCF86,0);bool woke=wakeSyntheticHalt(c,true);
   require(before&&woke,"Fade each original HALT counter state retains pending auxiliary byte before forced release",source*512+busy*2+plane);
  }else c->step(c);}
  bool exact=cpu->pc==0xC100&&cpu->sp==0xD000&&wakes==release&&cpu->a==0&&cpu->f.packed==0x80&&rd(c,0xC1B8)==0&&rd(c,0xC21F)==0&&rd(c,0xC220)==0&&
   rd(c,0xC221)==1&&rd(c,0xCF86)==0&&rd(c,0xFF8A)==0&&rd(c,0xFF8B)==0xA5&&!g->memory.ime&&rd(c,0xC773)==(pointer&255)&&rd(c,0xC774)==pointer>>8&&(rd(c,0xFF4F)&1)==plane;
  for(unsigned i=0;i<192;i++){unsigned component=(colors[source][i/3]>>(5*(i%3)))&31,delta=(31-component)*256;
   exact&=rd(c,0xC2A2+2*i)==0&&rd(c,0xC2A3+2*i)==0xF8&&rd(c,0xC422+2*i)==(delta&255)&&rd(c,0xC423+2*i)==delta>>8;
  }
  for(unsigned i=0;i<64;i++)exact&=rd(c,0xC222+2*i)==255&&rd(c,0xC223+2*i)==127;
  for(unsigned palette=0;palette<2;palette++)for(unsigned i=0;i<64;i++){wr(c,palette?0xFF6A:0xFF68,i);exact&=rd(c,palette?0xFF6B:0xFF69)==0x19;}
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)exact&=rd(c,0x8000+i)==0xA5;}
  require(exact,"Complete fade eight ticks plus pending idle waits original colors forced flag auxiliary release no IRQ upload",source*512+busy*2+plane);
 }
 }
 { /* Original marker classification and pre-mutation insertion coordinates. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 for(unsigned family=0;family<2;family++)for(unsigned sample=0;sample<(family?4096:131072);sample++){
  const unsigned offsets[]={0,0x40,0x80,255},values[]={0x85,0x96,0x9F,255};
  unsigned b=family?offsets[(sample>>8)&3]:(sample>>9),value=family?values[(sample>>10)&3]:(sample>>1)&255,e=family?sample&255:(sample&1)?255:0,d,flags;
  unsigned result=markerModel(b,value,e,&d,&flags);cpu->bc=(b<<8)|value;cpu->de=0x5A00|e;cpu->hl=0xC123;call(c,0x44D7);
  require(cpu->a==result&&cpu->f.packed==flags&&cpu->bc==((b<<8)|value)&&cpu->de==((d<<8)|e)&&cpu->hl==0xC123,
   "Marker classifier all offset value pairs both E branches and every E byte flags registers",family*131072+sample);
 }
 for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
 const unsigned starts[]={0x5334,0x537C,0x53C4,0x540C};
 for(unsigned x=0;x<256;x++)for(unsigned y=0;y<256;y++){
  unsigned mode=(x+y)&255,global=(x^y)&1,n=(x*73+y*29)&255,col=x;if(col>=5)col=(col+1)&255;if(col>=11)col=(col+1)&255;
  unsigned r4=((y<<4)|(y>>4))&255,r1=((y<<1)|(y>>7))&255,row=(r4+r1)&255,effective=global?2+(mode&1):mode;
  unsigned address=starts[effective<3?effective:3]+col+row,glyph=global&&(mode&1)&&y>=3?16:rd(c,address);
  wr(c,0xC765,global);wr(c,0xC76A,mode);wr(c,0xC766,x);wr(c,0xC767,y);wr(c,0xC76C,n);cpu->de=0x5A3C;
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x43F0;unsigned steps=0;while(cpu->pc!=0x444B&&steps++<2000)c->step(c);
  unsigned target=0xC74E + n;
  require(cpu->pc==0x444B&&cpu->sp==0xCFFC&&rd(c,0xCFFC)==(target&255)&&rd(c,0xCFFD)==target>>8,
   "Insertion all coordinate prefixes save wrapped list destination before mutation",x*256+y);
  require(cpu->hl==address&&cpu->a==glyph&&cpu->bc==((y<<8)|r4)&&cpu->de==0x5A3C&&rd(c,0xC76C)==n&&rd(c,0xC766)==x&&rd(c,0xC767)==y,
   "Insertion original mapped resource byte coordinate remap rotations high metadata prefix",x*256+y);
 }
 bool untouched=true;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)untouched&=rd(c,0x8000+i)==0xA5;}
 require(untouched,"Insertion coordinate prefixes leave both whole VRAM planes unchanged",0);
 }
 { /* Complete original insertion and redraw with independent post-list oracle. */
 const unsigned globals[]={0,1,2,255},starts[]={0x5334,0x537C,0x53C4,0x540C},previous[]={0x85,0x96,0x8A,0x99,0x9F,0xA3,0xD6,0xE3};
 unsigned resources[4][72],font[256][16];wr(c,0xFF40,0);wr(c,0x27FF,2);wr(c,0x2800,0);
 for(unsigned glyph=16;glyph<256;glyph++)for(unsigned i=0;i<16;i++)font[glyph][i]=rd(c,0x3F00+glyph*16+i);
 wr(c,0x27FF,0x0F);for(unsigned mode=0;mode<4;mode++)for(unsigned i=0;i<72;i++)resources[mode][i]=rd(c,starts[mode]+i);
 for(unsigned family=0;family<2;family++)for(unsigned sample=0;sample<(family?16:3840);sample++){
  unsigned plane=sample&1,k=sample>>1,meta,x,y,mode,global,entry=family?0x41C5:0x43F0;
  if(family){mode=k>>1;global=k&1;meta=0;x=sample%15;y=(sample>>2)%4;}
  else{meta=k%2;k/=2;x=k%15;k/=15;y=k%4;k/=4;global=globals[k%4];mode=k/4;}
  unsigned effective=global&1?2+(mode&1):mode,col=x+(x>=5)+(x>=10),glyph=global&&(mode&1)&&y>=3?16:resources[effective][y*18+col];
  unsigned prev=previous[(x+y+meta)&7],d,flags;bool marker=glyph>=254;
  bool allowed=marker?(markerModel(0,prev,glyph,&d,&flags)||markerModel(0x40,prev,glyph,&d,&flags)):meta==0;
  unsigned capacity=meta?2:(global&1)?16:8,n=allowed?3:2,markers=allowed&&marker?1:0,list[4]={16,prev,0,0};
  if(allowed){if(marker){list[1]=glyph;list[2]=prev;}else list[2]=glyph;}
  unsigned char expected[2][8192];memset(expected,0xA5,sizeof(expected));unsigned cursor=0,lastTile=0xA5;
  unsigned rawX=global&1?1:5,origin=0x9880+rawX+1,rowOrigin=0x9860+rawX+1,count=n-markers;
  if(allowed){for(unsigned i=0;i<n;i++){
   unsigned g=list[i],dest=0x96B0-16*(70+i),address=origin+cursor-(g>=254?32:0);
   lastTile=0x6B-(70+i);expected[0][address-0x8000]=lastTile;expected[1][address-0x8000]=0x23;
   for(unsigned j=0;j<16;j++)expected[1][dest-0x8000+j]=font[g][j];if(g<254)cursor++;
  }
  if(count<capacity){expected[0][0x1882+count]=0x89;expected[1][0x1882+count]=0;expected[0][rowOrigin+count-0x8000]=0x88;expected[1][rowOrigin+count-0x8000]=7;
   for(unsigned i=count+1;i<capacity;i++){expected[0][0x1882+i]=0x8A;expected[1][0x1882+i]=0;}}
  }
  wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);unsigned restored[8];for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x4000+i);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC765,global);wr(c,0xC76A,mode);wr(c,0xC766,x);wr(c,0xC767,y);wr(c,0xC76C,2);wr(c,0xC76D,0);wr(c,0xC76E,0);wr(c,0xC76F,capacity);
  wr(c,0xC74C,0x5A);wr(c,0xC74D,0x3C);wr(c,0xC74E,16);wr(c,0xC74F,prev);wr(c,0xC750,0);wr(c,0xC751,0xA5);wr(c,0xC752,0x3C);
  wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1AF,1);wr(c,0xC1BF,1);wr(c,0xC1B1,0x23);wr(c,0xC1B8,0);wr(c,0xC1B9,0);wr(c,0xC1C0,0);wr(c,0xC1C1,0);
  wr(c,0xC1C2,0x3C);wr(c,0xC1C3,0xA5);wr(c,0xC1BC,0x3C);wr(c,0xC1BD,0x5A);wr(c,0xC1BA,0x3C);wr(c,0xC1AB,0xA5);wr(c,0xC1AC,0x5A);wr(c,0xC770,0xA5);wr(c,0xC771,0x3C);
  wr(c,0xC1C4,0);wr(c,0xC772,1);wr(c,0xC220,0);wr(c,0xFF97,1);wr(c,0xFF98,0);wr(c,0xFF99,0);wr(c,0xFF40,0x91);callWithLimit(c,entry,2000000);
  bool decorate=allowed&&count<capacity;unsigned end=0xC74E + n + 1;struct GB *g=c->board;
  bool exact=rd(c,0xC76C)==n&&rd(c,0xC76D)==markers&&rd(c,0xC76E)==0&&rd(c,0xC76F)==capacity&&rd(c,0xC74C)==0x5A&&rd(c,0xC74D)==0x3C&&rd(c,0xC752)==0x3C&&
   rd(c,0xC1B8)==0&&rd(c,0xC1B9)==0&&(rd(c,0xFF4F)&1)==plane;
  for(unsigned i=0;i<4;i++)exact&=rd(c,0xC74E + i)==(i<=n?list[i]:0xA5);
  if(allowed){exact&=rd(c,0xC1C2)==0&&rd(c,0xC1C3)==lastTile&&rd(c,0xC1AB)==(end&255)&&rd(c,0xC1AC)==end>>8&&rd(c,0xC1BC)==(decorate?0:cursor)&&rd(c,0xC1BD)==0&&
    rd(c,0xC1BA)==(decorate?0:0x3C)&&rd(c,0xC770)==(decorate?count:0xA5)&&rd(c,0xC771)==(decorate?1:0x3C)&&g->memory.hdmaRemaining==0&&rd(c,0xC113)==0x0F&&rd(c,0xC114)==0;
   for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==restored[i];
  }else exact&=rd(c,0xC1C2)==0x3C&&rd(c,0xC1C3)==0xA5&&rd(c,0xC1AB)==0xA5&&rd(c,0xC1AC)==0x5A&&rd(c,0xC1BC)==0x3C&&rd(c,0xC1BD)==0x5A&&rd(c,0xC1BA)==0x3C;
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)exact&=rd(c,0x8000+i)==expected[bank][i];}
  require(exact,"Complete original selected insertion capacity marker acceptance rejection dispatcher exact VRAM",family*4096+sample);
 }
 /* Complete early rejection when target-2 already contains a marker. */
 for(unsigned selected=0;selected<2;selected++)for(unsigned existing=0;existing<2;existing++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++){
  unsigned glyph=254+selected,mode=0,index=0;bool found=false;
  for(unsigned m=0;m<2&&!found;m++)for(unsigned i=0;i<72;i++)if(resources[m][i]==glyph){mode=m;index=i;found=true;break;}
  if(!found){fprintf(stderr,"Missing marker in original resource\n");exit(10);}
  unsigned y=index/18,pos=index%18,x=(pos/6)*5+pos%6;
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0x27FF,0x0F);wr(c,0x2800,0);wr(c,0xC765,0);wr(c,0xC76A,mode);wr(c,0xC766,x);wr(c,0xC767,y);
  wr(c,0xC76C,2);wr(c,0xC76D,1);wr(c,0xC76F,8);wr(c,0xC74E,254+existing);wr(c,0xC74F,0x9F);wr(c,0xC750,0);wr(c,0xC751,0x3C);
  wr(c,0xC1AB,0xA5);wr(c,0xC1AC,0x5A);wr(c,0xC1C2,0x3C);if(lcd)wr(c,0xFF40,0x91);call(c,0x43F0);
  bool exact=rd(c,0xC76C)==2&&rd(c,0xC76D)==1&&rd(c,0xC74E)==254+existing&&rd(c,0xC74F)==0x9F&&rd(c,0xC750)==0&&rd(c,0xC751)==0x3C&&
   rd(c,0xC1AB)==0xA5&&rd(c,0xC1AC)==0x5A&&rd(c,0xC1C2)==0x3C&&(rd(c,0xFF4F)&1)==plane;
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)exact&=rd(c,0x8000+i)==0xA5;}
  require(exact,"Insertion selected FE FF rejects existing marker two bytes back before redraw LCDoff on",selected*8+existing*4+plane*2+lcd);
 }
 /* Short-list marker paths: measure the two-byte backward read before executing it. */
 for(unsigned which=0;which<2;which++)for(unsigned n=0;n<2;n++){
  unsigned glyph=254+which,mode=0,index=0;bool found=false;
  for(unsigned m=0;m<2&&!found;m++)for(unsigned i=0;i<72;i++)if(resources[m][i]==glyph){mode=m;index=i;found=true;break;}
  require(found,"Original grid contains requested marker for bounded short-list prefix",which*2+n);
  unsigned y=index/18,position=index%18,x=(position/6)*5+position%6;
  wr(c,0xFF40,0);wr(c,0x27FF,0x0F);wr(c,0xC765,0);wr(c,0xC76A,mode);wr(c,0xC766,x);wr(c,0xC767,y);wr(c,0xC76C,n);
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x43F0;
  unsigned steps=0;while(cpu->pc!=0x445D&&steps++<2000)c->step(c);
  require(cpu->pc==0x445D&&cpu->hl==0xC74C + n&&cpu->e==glyph&&cpu->sp==0xCFFE&&rd(c,0xC76C)==n,
   "Artificial short-list marker prefix stops before read at list-start minus2 pluscount",which*2+n);
 }
 }
 { /* Full grid/modecycle: independent glyph/VRAM model, original streams. */
 const unsigned choices[]={0,1,2,255},starts[]={0x5334,0x537C,0x53C4,0x540C};unsigned fonts[256][16],streams[4][72],resource[306],footer[2][40];
 wr(c,0xFF40,0);wr(c,0x27FF,2);wr(c,0x2800,0);
 for(unsigned glyph=16;glyph<256;glyph++)for(unsigned i=0;i<16;i++)fonts[glyph][i]=rd(c,0x3F00+glyph*16+i);
 wr(c,0x27FF,0x0F);for(unsigned variant=0;variant<4;variant++)for(unsigned i=0;i<72;i++)streams[variant][i]=rd(c,starts[variant]+i);
 for(unsigned i=0;i<306;i++)resource[i]=rd(c,0x5334+i);
 for(unsigned which=0;which<2;which++)for(unsigned i=0;i<40;i++)footer[which][i]=rd(c,(which?0x4F0C:0x4F34)+i);
 for(unsigned family=0;family<3;family++)for(unsigned sample=0;sample<(family==0?32:family==1?1024:16);sample++){
  unsigned plane=sample&1,global,old,input,entry;
  if(family==0){old=choices[sample>>3];global=choices[(sample>>1)&3];input=old;entry=0x468B;}
  else{old=family==1?sample>>2:choices[sample>>2];global=(sample>>1)&1;input=(old+1)&255;if(input==4)input=0;entry=family==1?0x455D:0x41C5;}
  unsigned effective=global&1?2+(input&1):input,variant=effective<3?effective:3;
  unsigned char expected[2][8192];memset(expected,0xA5,sizeof(expected));
  unsigned left=input<2?0x30:0x10,right=left+0x40;
  expected[0][0x18E1+left]=0x88;expected[1][0x18E1+left]=7;expected[0][0x18E1+right]=0x88;expected[1][0x18E1+right]=7;
  for(unsigned i=0;i<20;i++){expected[0][0x19E0+i]=footer[global!=0][i];expected[1][0x19E0+i]=footer[global!=0][20+i];}
  unsigned pointer=starts[variant],counter=0,lastTile=0,lastCol=0,lastRow=0,end=0,workD=0;
  for(unsigned row=0;row<4;row++)for(unsigned column=0;column<3;column++){
   if(column==0)workD=row;
   bool fallback=global!=0&&(input&1)&&workD>=3;if(fallback)pointer=0x5454;
   unsigned col=column*6,localRow=row*2,n=0;
   while(pointer+n<0x5466&&resource[pointer+n-0x5334]!=0)n++;
   for(unsigned i=0;i<n;i++){
    unsigned glyph=resource[pointer+i-0x5334];
    if(glyph<16){fprintf(stderr,"Unexpected grid control in glyph oracle\n");exit(10);}
    unsigned address=0x9800+32*(8+localRow-(glyph>=254?1:0))+1+col,dest=0x96B0-counter*16;
    workD=(8+localRow-(glyph>=254?1:0))>>3;
    lastTile=(0x6B-counter)&255;expected[0][address-0x8000]=lastTile;expected[1][address-0x8000]=0x23;
    for(unsigned j=0;j<16;j++)expected[1][dest-0x8000+j]=fonts[glyph][j];counter++;
    if(glyph<254){col++;if(col>=18){col=0;localRow+=2;if(localRow==10)localRow=0;}}
   }
   pointer+=n+1;end=pointer;
   lastCol=col;lastRow=localRow;if(column<2)counter++;
  }
  if(family){unsigned base=effective==1?0x96:effective==2?0x98:effective==3?(global?0x96:0x92):0x94;
   const unsigned addresses[]={0x1A02,0x1A08,0x1A0E},tiles[]={base,0x8E,0x90};
   for(unsigned i=0;i<3;i++){expected[0][addresses[i]]=tiles[i];expected[0][addresses[i]+1]=tiles[i]+1;expected[1][addresses[i]]=0x23;expected[1][addresses[i]+1]=0x5A;}
  }
  wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);unsigned restored[8];for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x4000+i);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC765,global);wr(c,0xC76A,old);wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1AF,1);wr(c,0xC1BF,1);wr(c,0xC1B1,0x23);
  wr(c,0xC1B8,0);wr(c,0xC1B9,0);wr(c,0xC1C0,0);wr(c,0xC1C1,0);wr(c,0xC775,0xA5);wr(c,0xC776,0x3C);wr(c,0xC777,0x23);wr(c,0xC778,0x5A);
  wr(c,0xC772,1);wr(c,0xC220,0);wr(c,0xFF97,4);wr(c,0xFF98,0);wr(c,0xFF99,0);cpu->a=input;wr(c,0xFF40,0x91);callWithLimit(c,entry,10000000);
  struct GB *g=c->board;bool exact=rd(c,0xC76A)==input&&rd(c,0xC765)==global&&rd(c,0xC1C2)==0&&rd(c,0xC1C3)==lastTile&&rd(c,0xC1B8)==0&&rd(c,0xC1B9)==0&&
   rd(c,0xC1AB)==(end&255)&&rd(c,0xC1AC)==end>>8&&rd(c,0xC1BC)==lastCol&&rd(c,0xC1BD)==lastRow&&rd(c,0xC1BA)==0&&
   rd(c,0xC1A4)==1&&rd(c,0xC1A7)==8&&rd(c,0xC1A8)==18&&rd(c,0xC1A9)==5&&rd(c,0xC1AA)==1&&rd(c,0xC770)==right&&rd(c,0xC771)==1&&
   (rd(c,0xFF4F)&1)==0&&rd(c,0xC113)==0x0F&&rd(c,0xC114)==0&&g->memory.hdmaRemaining==0&&rd(c,0xC777)==0x23&&rd(c,0xC778)==0x5A;
  exact&=rd(c,0xC775)==(family?0x90:0xA5)&&rd(c,0xC776)==(family?0x91:0x3C);for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==restored[i];
  if(!exact)fprintf(stderr,"Grid fields family=%u sample=%u ptr=%02X%02X/%04X cursor=%u,%u/%u,%u tile=%u/%u mode=%u/%u mark=%u/%u\n",family,sample,rd(c,0xC1AC),rd(c,0xC1AB),end,rd(c,0xC1BC),rd(c,0xC1BD),lastCol,lastRow,rd(c,0xC1C3),lastTile,rd(c,0xC76A),input,rd(c,0xC770),right);
  wr(c,0xFF40,0);bool reported=false;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){unsigned actual=rd(c,0x8000+i);if(actual!=expected[bank][i]&&!reported){fprintf(stderr,"Grid VRAM family=%u sample=%u bank=%u address=%04X actual=%02X expected=%02X\n",family,sample,bank,0x8000+i,actual,expected[bank][i]);reported=true;}exact&=actual==expected[bank][i];}}
  require(exact,"Original grid streams full modecycle dispatcher all old bytes exact VRAM glyph HDMA mapper",family*2048+sample);
 }
 }
 { /* Full original redraw and nonempty trim/action chains; no stubbed callees. */
 const unsigned modes[]={0,1,2,255},glyphs[]={16,127,253,254,255};unsigned font[5][16];
 wr(c,0xFF40,0);wr(c,0x27FF,2);wr(c,0x2800,0);
 for(unsigned gi=0;gi<5;gi++)for(unsigned i=0;i<16;i++)font[gi][i]=rd(c,0x3F00+glyphs[gi]*16+i);
 for(unsigned family=0;family<4;family++){
  unsigned cases=family==0?512:family==1?216:16;
  for(unsigned sample=0;sample<cases;sample++){
   unsigned plane=sample&1,mode=0,n=0,count=0,markers=0,capacity=0,offset=0,entry=0x45A0,markerGlyph=0;
   if(family==0){mode=sample>>1;count=(mode*73)&255;capacity=(mode*29)&255;offset=(mode*17)&255;}
   else if(family==1){unsigned k=sample>>1,oi=k%3;k/=3;unsigned ci=k%3;k/=3;unsigned ni=k%3;k/=3;mode=modes[k];n=ni==0?0:ni==1?1:8;
    capacity=(mode&1)?16:8;count=ci==0?0:ci==1?n:capacity+1;markers=ci==1?253:0;offset=oi*2;}
   else if(family==2){mode=modes[sample>>2];markerGlyph=(sample>>1)&1?255:254;n=2;markers=1;count=1;capacity=(mode&1)?16:8;}
   else{mode=modes[sample>>2];n=1;count=1;capacity=(mode&1)?16:8;entry=(sample>>1)&1?0x41C5:0x451F;}
   unsigned rawX=(mode&1)?1:5,textOrigin=0x9880+rawX+1,rowOrigin=0x9860+rawX+1;
   unsigned char expected[2][8192];memset(expected,0xA5,sizeof(expected));
   wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);
   unsigned restored[8];for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x4000+i);
   for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
   for(unsigned i=0;i<n;i++){
    unsigned gi=family==2?(i==0?(markerGlyph==254?3:4):0):i%3,glyph=glyphs[gi],dest=0x96B0-16*(70+i);
    wr(c,0xC74E + i,glyph);
    for(unsigned j=0;j<16;j++)expected[1][dest-0x8000+j]=font[gi][j];
    unsigned tileAddress=textOrigin+(family==2?0:i)-(glyph>=254?32:0);
    expected[0][tileAddress-0x8000]=0x6B-(70+i);expected[1][tileAddress-0x8000]=0x23;
   }
   wr(c,0xC74E + n,0);
   if(family==3){wr(c,0xC74F,127);wr(c,0xC750,0);}
   bool decorate=count<capacity;
   if(decorate){unsigned first=0x9882+count+offset;
    expected[0][first-0x8000]=0x89;expected[1][first-0x8000]=0;
    expected[0][rowOrigin+count-0x8000]=0x88;expected[1][rowOrigin+count-0x8000]=7;
    for(unsigned i=count+1;i<capacity;i++){expected[0][0x9882+i+offset-0x8000]=0x8A;expected[1][0x9882+i+offset-0x8000]=0;}
   }
   wr(c,0xFF4F,plane);wr(c,0xC765,mode);wr(c,0xC76C,family==3?2:(count+markers)&255);wr(c,0xC76D,markers);wr(c,0xC76E,offset);wr(c,0xC76F,capacity);
   wr(c,0xC770,0xA5);wr(c,0xC771,0x3C);wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1AF,1);wr(c,0xC1BF,1);wr(c,0xC1B1,0x23);
   wr(c,0xC1B8,0);wr(c,0xC1B9,0);wr(c,0xC1BA,0x5A);wr(c,0xC1C3,0xA5);wr(c,0xC1C0,0);wr(c,0xC1C1,0);
   wr(c,0xC772,1);wr(c,0xC220,0);wr(c,0xFF97,2);wr(c,0xFF98,0);wr(c,0xFF99,0);
   if(family)wr(c,0xFF40,0x91);callWithLimit(c,entry,2000000);
   unsigned end=0xC74E + n + 1;struct GB *g=c->board;
   bool exact=rd(c,0xC1B8)==0&&rd(c,0xC1B9)==0&&rd(c,0xC1BE)==0&&rd(c,0xC1AB)==(end&255)&&rd(c,0xC1AC)==end>>8&&
    rd(c,0xC1C2)==0&&rd(c,0xC1C3)==(n?0x6B-(70+n-1):0xA5)&&rd(c,0xC1A4)==rawX+1&&rd(c,0xC1A7)==4&&
    rd(c,0xC1A8)==((mode&1)?17:9)&&rd(c,0xC1A9)==1&&rd(c,0xC1AA)==0&&rd(c,0xC1BA)==(decorate?0:0x5A)&&
    rd(c,0xC1BC)==(decorate?0:family==2?1:n)&&rd(c,0xC1BD)==0&&rd(c,0xC770)==(decorate?count:0xA5)&&rd(c,0xC771)==(decorate?1:0x3C)&&
    rd(c,0xC76C)==((count+markers)&255)&&rd(c,0xC76D)==markers&&rd(c,0xC76E)==offset&&rd(c,0xC76F)==capacity&&(rd(c,0xFF4F)&1)==plane;
   if(n){exact&=g->memory.hdmaRemaining==0&&rd(c,0xC113)==0x0F&&rd(c,0xC114)==0;for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==restored[i];}
   if(family==3)exact&=rd(c,0xC74E)==16&&rd(c,0xC74F)==0;
   wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)exact&=rd(c,0x8000+i)==expected[bank][i];}
   require(exact,"Complete list redraw glyphs markers wrapped metadata decorations nonempty trim action exact VRAM",family*1024+sample);
  }
 }
 }
 { /* Redraw dependencies: byte arithmetic and row address before any write. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 for(unsigned total=0;total<256;total++)for(unsigned markers=0;markers<256;markers++){
  unsigned count=(total-markers)&255,capacity=markers;
  unsigned flags=0x40|(count==capacity?0x80:0)|((count&15)<(capacity&15)?0x20:0)|(count<capacity?0x10:0);
  wr(c,0xC76C,total);wr(c,0xC76D,markers);wr(c,0xC76F,capacity);wr(c,0xC76E,0xA5);cpu->de=0x5A3C;cpu->hl=0xC123;call(c,0x4496);
  require(cpu->a==(count<capacity)&&cpu->b==count&&cpu->c==capacity&&cpu->f.packed==flags&&cpu->de==0x5A3C&&cpu->hl==0xC123&&
   rd(c,0xC76C)==total&&rd(c,0xC76D)==markers&&rd(c,0xC76F)==capacity&&rd(c,0xC76E)==0xA5,
   "Nonmarker predicate all subtraction pairs and all count capacity pairs bytewrap flags",total*256+markers);
 }
 for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
 for(unsigned x=0;x<256;x++)for(unsigned y=0;y<256;y++){
  unsigned offset=(x+y)&255,count=(x*73+y*29)&255,plane=(x^y)&1,dest=(0x9800+32*((y-1)&255)+x+offset)&65535;
  wr(c,0xFF4F,plane);wr(c,0xC1A4,x);wr(c,0xC1A7,y);wr(c,0xC770,offset);wr(c,0xC771,count);
  wr(c,0xC1BC,0xA5);wr(c,0xC1BD,0x3C);wr(c,0xC1BA,0x5A);wr(c,0xC1B8,0xA5);
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x474C;unsigned steps=0;
  while(cpu->pc!=0x4788&&steps++<1000)c->step(c);
  require(cpu->pc==0x4788&&cpu->sp==0xCFFC&&rd(c,0xCFFD)==plane&&rd(c,0xCFFC)==(plane?0x20:0xA0),
   "Marked row all coordinate prefixes stop before VRAM write saved AF",x*256+y);
  require(cpu->hl==dest&&cpu->bc==count*256&&cpu->de==0x88&&cpu->a==count&&(rd(c,0xFF4F)&1)==0&&rd(c,0xC1BC)==0&&
   rd(c,0xC1BD)==0&&rd(c,0xC1BA)==0&&rd(c,0xC1B8)==0xA5&&rd(c,0xC1A4)==x&&rd(c,0xC1A7)==y&&rd(c,0xC770)==offset&&rd(c,0xC771)==count,
   "Marked row wrapped origin fields and counter at first write no geometry clamp",x*256+y);
 }
 bool untouched=true;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)untouched&=rd(c,0x8000+i)==0xA5;}
 require(untouched,"All marked row prefixes leave both entire VRAM planes untouched",0);
 for(unsigned count=0;count<256;count++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++){
  unsigned x=(count*73)&255,y=1+count%40,offset=(count*29)&255,origin=0x9800+32*(y-1)+x+offset,n=count?count:256;
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC1A4,x);wr(c,0xC1A7,y);wr(c,0xC770,offset);wr(c,0xC771,count);wr(c,0xC1B8,0x5A);wr(c,0xC1A3,0x23);
  wr(c,0xC1BC,0xA5);wr(c,0xC1BD,0x3C);wr(c,0xC1BA,0x5A);if(lcd)wr(c,0xFF40,0x91);callWithLimit(c,0x474C,2000000);
  bool exact=cpu->hl==origin+n&&cpu->bc==0&&cpu->de==0x88&&cpu->a==plane&&cpu->f.packed==(plane?0x20:0xA0)&&
   (rd(c,0xFF4F)&1)==plane&&rd(c,0xC1BC)==0&&rd(c,0xC1BD)==0&&rd(c,0xC1BA)==0&&rd(c,0xC1B8)==0x5A&&rd(c,0xC1A3)==0x23&&
   rd(c,0xC1A4)==x&&rd(c,0xC1A7)==y&&rd(c,0xC770)==offset&&rd(c,0xC771)==count;
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned address=0x8000;address<0xA000;address++){
   bool written=address>=origin&&address<origin+n;exact&=rd(c,address)==(written?(bank?7:0x88):0xA5);
  }}
  require(exact,"Marked row all byte counts full return exact VRAM LCDoff on restored VBK registers",count*4+plane*2+lcd);
 }
 }
 { /* Frame writes: independent row/cell memory model, including overlapping rows. */
 const unsigned attrs[]={0,1,0x23,255};
 for(unsigned family=0;family<3;family++){
  unsigned cases=family==0?1024:family==1?512:64;
  for(unsigned sample=0;sample<cases;sample++){
   unsigned plane=sample&1,lcd=family==1?0:(sample>>1)&1;
   unsigned kind=family==0?sample>>2:family==1?1:((sample>>5)?2:1);
   unsigned width=family==0?1+kind%29:family==1?sample>>1:kind==1?18:16;
   unsigned height=family==0?1+kind%8:family==1?1:kind==1?5:1;
   unsigned origin=family==2?(kind==1?0x98C0:0x9841):0x8000;
   unsigned attr=attrs[(sample>>2)&3],columns=width?width:256,rows=((height*2)&255)+2,base=kind==1?0x6C:0x75;
   unsigned char expected[2][8192];memset(expected,0xA5,sizeof(expected));
   for(unsigned row=0;row<rows;row++)for(unsigned col=0;col<columns+2;col++){
    unsigned address=origin-0x8000+row*32+col;
    if(address>=8192){fprintf(stderr,"Frame model outside VRAM\n");exit(10);}
    unsigned tile=base+(row==0?0:row==rows-1?6:3)+(col==0?0:col==columns+1?2:1);
    expected[0][address]=tile;expected[1][address]=attr;
   }
   wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
   for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
   wr(c,0xFF4F,plane);wr(c,0xC1A3,attr);wr(c,0xC1A4,0x3C);wr(c,0xC1A7,0x5A);wr(c,0xC1A8,width);wr(c,0xC1A9,height);wr(c,0xC1AA,kind);
   wr(c,0xC1AB,0xA5);wr(c,0xC1B8,0x5A);wr(c,0xC1BC,0xA5);wr(c,0xC1BD,0x3C);
   unsigned entry=0x1FB,expectedD=0xA5;cpu->hl=origin;cpu->de=0xA500;
   if(family==2){entry=0x1E6;cpu->a=kind==1?0:3;cpu->c=(sample>>4)&1?255:0;cpu->de=0x5268;wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);expectedD=0x98;}
   if(lcd)wr(c,0xFF40,0x91);callWithLimit(c,entry,2000000);
   bool exact=cpu->hl==origin+(rows-1)*32+columns+1&&cpu->bc==0&&cpu->de==((expectedD<<8)|(base+8))&&cpu->a==plane&&
    cpu->f.packed==(plane?0x20:0xA0)&&(rd(c,0xFF4F)&1)==plane&&rd(c,0xC1A8)==width&&rd(c,0xC1A9)==height&&rd(c,0xC1AA)==kind&&
    rd(c,0xC1A3)==attr&&rd(c,0xC1AB)==0xA5&&rd(c,0xC1B8)==0x5A&&rd(c,0xC1BC)==0xA5&&rd(c,0xC1BD)==0x3C;
   if(family==2)exact&=rd(c,0xC1A4)==(kind==1?1:2)&&rd(c,0xC1A7)==(kind==1?8:4)&&rd(c,0xC1A5)==(origin&255)&&rd(c,0xC1A6)==origin>>8;
   else exact&=rd(c,0xC1A4)==0x3C&&rd(c,0xC1A7)==0x5A;
   wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)exact&=rd(c,0x8000+i)==expected[bank][i];}
   require(exact,"Frame complete all kinds widths original preparation LCDoff on exact planes registers guards",family*1024+sample);
  }
 }
 /* Zero doubled height would leave VRAM: stop before the last middle row at A000. */
 for(unsigned heightCase=0;heightCase<2;heightCase++)for(unsigned widthCase=0;widthCase<2;widthCase++)for(unsigned plane=0;plane<2;plane++){
  unsigned width=widthCase?29:1,base=0x6C;unsigned char expected[2][8192];memset(expected,0xA5,sizeof(expected));
  for(unsigned row=0;row<256;row++)for(unsigned col=0;col<width+2;col++){
   unsigned i=row*32+col;expected[0][i]=base+(row?3:0)+(col==0?0:col==width+1?2:1);expected[1][i]=0x23;
  }
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC1A3,0x23);wr(c,0xC1A8,width);wr(c,0xC1A9,heightCase?128:0);wr(c,0xC1AA,1);
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->hl=0x8000;cpu->de=0xA500;cpu->pc=0x1FB;
  unsigned steps=0;while(!(cpu->pc==0x2C79&&cpu->hl==0xA000)&&steps++<2000000)c->step(c);
  unsigned sample=heightCase*4+widthCase*2+plane;
  require(cpu->pc==0x2C79&&cpu->hl==0xA000&&cpu->sp==0xCFFC&&cpu->bc==1&&cpu->de==0xA56F&&(rd(c,0xFF4F)&1)==0,
   "Frame height0 128 prefix reaches row256 before leaving VRAM with saved VBK on stack",sample);
  bool exact=true;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)exact&=rd(c,0x8000+i)==expected[bank][i];}
  require(exact,"Frame height0 128 prefix exact top and255 middle rows no outside writes",sample);
 }
 }
 { /* Indexed text setup and blocking interpreter; original reached records. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,0x0F);wr(c,0x2800,0);
 unsigned offsets[256],records[4][8];
 for(unsigned row=0;row<256;row++){unsigned p=0x2FF1+((row*2)&255);offsets[row]=rd(c,p)|(rd(c,p+1)<<8);}
 for(unsigned index=0;index<4;index++)for(unsigned field=0;field<8;field++)records[index][field]=rd(c,0x5268+index*8+field);
 for(unsigned x=0;x<256;x++)for(unsigned y=0;y<256;y++){
  unsigned index=(x+y)&255,address=0xD000+8*index,base=((x^y)&1)?0xFFF0:0x9800;
  unsigned width=(x^y)&255,height=(x*73+y*29)&255,kind=(x+y*53)&255,fallback=(x*53+y*11)&255;
  const unsigned fields[]={x,y,width,height,kind,0xA5,0x5A,0x3C};
  for(unsigned i=0;i<8;i++)wr(c,address+i,fields[i]);
  wr(c,0xC1A3,0x23);wr(c,0xC1AB,0xA5);wr(c,0xC1B5,base);wr(c,0xC1B6,base>>8);
  cpu->a=index;cpu->c=fallback;cpu->de=0xD000;call(c,0x1E3);unsigned dest=(base+offsets[y]+x)&65535;
  require(rd(c,0xC1A4)==((x+1)&255)&&rd(c,0xC1A7)==((y+2)&255)&&rd(c,0xC1A8)==width&&rd(c,0xC1A9)==(height?height:fallback)&&
   rd(c,0xC1AA)==kind&&rd(c,0xC1A5)==(dest&255)&&rd(c,0xC1A6)==(dest>>8)&&rd(c,0xC1A3)==0x23&&rd(c,0xC1AB)==0xA5&&
   cpu->hl==dest&&cpu->de==dest&&cpu->bc==((base&0xFF00)|fallback)&&cpu->a==dest>>8&&(cpu->f.packed&0xF0)==(kind?0:0x80)&&rd(c,0xFF9E)==fallback,
   "Indexed text all coordinate bytes record8 stride wrapped address fields flags",x*256+y);
 }
 for(unsigned fallback=0;fallback<256;fallback++){
  const unsigned fields[]={5,2,4,0,fallback};for(unsigned i=0;i<5;i++)wr(c,0xD000+i,fields[i]);
  wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);cpu->a=0;cpu->c=fallback;cpu->de=0xD000;call(c,0x1E3);
  require(rd(c,0xC1A9)==fallback&&rd(c,0xFF9E)==fallback&&rd(c,0xC1AA)==fallback&&cpu->hl==0x9845,
   "Indexed text zero-height fallback all input C bytes",fallback);
 }
 const unsigned fallbacks[]={0,1,255},bases[]={0,0x9800};
 for(unsigned index=0;index<4;index++)for(unsigned f=0;f<3;f++)for(unsigned b=0;b<2;b++)for(unsigned plane=0;plane<2;plane++){
  unsigned dest=(bases[b]+offsets[records[index][1]]+records[index][0])&65535;
  wr(c,0xFF4F,plane);wr(c,0xC1B5,bases[b]);wr(c,0xC1B6,bases[b]>>8);cpu->a=index;cpu->c=fallbacks[f];cpu->de=0x5268;call(c,0x1E3);
  require(rd(c,0xC1A4)==records[index][0]+1&&rd(c,0xC1A7)==records[index][1]+2&&rd(c,0xC1A8)==records[index][2]&&
   rd(c,0xC1A9)==records[index][3]&&rd(c,0xC1AA)==records[index][4]&&cpu->hl==dest&&cpu->de==dest&&(rd(c,0xFF4F)&1)==plane,
   "Indexed text actual four ROM records fields without VRAM write",index*12+f*4+b*2+plane);
 }
 const unsigned attrs[]={0,1,0x23,255};
 for(unsigned index=1;index<=2;index++)for(unsigned fallback=0;fallback<2;fallback++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++)for(unsigned attr=0;attr<4;attr++){
  wr(c,0xFF40,0);for(unsigned p=0;p<2;p++){wr(c,0xFF4F,p);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1A3,attrs[attr]);wr(c,0xC1B8,0x5A);
  wr(c,0xC1BC,0xA5);wr(c,0xC1BD,0x3C);cpu->a=index;cpu->c=fallback?255:0;cpu->de=0x5268;if(lcd)wr(c,0xFF40,0x91);call(c,0x1E6);
  unsigned origin=0x9800+offsets[records[index][1]+1]+records[index][0]+1,width=records[index][2];
  bool exact=rd(c,0xC1AA)==0&&rd(c,0xC1A9)==1&&rd(c,0xC1BC)==0&&rd(c,0xC1BD)==0&&rd(c,0xC1B8)==0x5A&&(rd(c,0xFF4F)&1)==plane;
  wr(c,0xFF40,0);for(unsigned p=0;p<2;p++){wr(c,0xFF4F,p);for(unsigned address=0x8000;address<0xA000;address++){
   bool filled=(address>=origin&&address<origin+width)||(address>=origin+32&&address<origin+32+width);
   exact&=rd(c,address)==(filled?(p?attrs[attr]:0x79):0xA5);
  }}
  require(exact,"Original region prep zero-kind complete fill exact VRAM LCDoff on",(index-1)*32+fallback*16+plane*8+lcd*4+attr);
 }
 for(unsigned choice=0;choice<2;choice++)for(unsigned fallback=0;fallback<2;fallback++)for(unsigned plane=0;plane<2;plane++)for(unsigned b=0;b<2;b++){
  unsigned index=choice?3:0,base=b?0x9800:0,dest=(base+offsets[records[index][1]]+records[index][0])&65535;
  wr(c,0xFF40,0);wr(c,0xFF4F,plane);wr(c,0xC1B5,base);wr(c,0xC1B6,base>>8);cpu->a=index;cpu->c=fallback?255:0;cpu->de=0x5268;
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
  wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x1E6;unsigned steps=0;while(cpu->pc!=0x2BFE&&steps++<1000)c->step(c);
  unsigned sample=choice*8+fallback*4+plane*2+b;
  require(cpu->pc==0x2BFE&&cpu->sp==0xCFFC,"Nonzero-kind original preparation stops before frame helper",sample);
  require(rd(c,0xC1AA)==records[index][4]&&rd(c,0xC1A9)==records[index][3]&&cpu->hl==dest&&cpu->de==dest&&(rd(c,0xFF4F)&1)==plane,
   "Nonzero-kind original record setup fields retained at frame boundary",sample);
 }
 wr(c,0xD800,0);
 for(unsigned remaining=0;remaining<256;remaining++){
  wr(c,0xC1B8,(remaining*73)&255);wr(c,0xC1B9,remaining);wr(c,0xC1AD,0);wr(c,0xC1AE,0xD8);
  wr(c,0xC1BA,0xA5);wr(c,0xC1BF,0x5A);wr(c,0xC1C2,0x3C);cpu->bc=(remaining<<8)|(255-remaining);cpu->hl=0xD800;call(c,0x1EF);
  require(rd(c,0xC1B8)==0&&rd(c,0xC1B9)==0&&rd(c,0xC1AB)==1&&rd(c,0xC1AC)==0xD8&&rd(c,0xC1BC)==remaining&&rd(c,0xC1BD)==255-remaining&&
   rd(c,0xC1BE)==0&&rd(c,0xC1BA)==0xA5&&rd(c,0xC1BF)==0x5A&&rd(c,0xC1C2)==0x3C,"Blocking zero controls repeat all counter bytes then clear state",remaining);
 }
 const unsigned controls[]={2,1,3,0xA5,1,15,0};for(unsigned i=0;i<7;i++)wr(c,0xD800+i,controls[i]);
 for(unsigned remaining=0;remaining<256;remaining++){
  wr(c,0xC1B8,0xA5);wr(c,0xC1B9,remaining);wr(c,0xC1BA,0x5A);wr(c,0xC1C0,0);wr(c,0xC1C1,0);wr(c,0xC1A9,16);
  cpu->bc=0x0102;cpu->hl=0xD800;call(c,0x1EF);
  require(rd(c,0xC1B8)==0&&rd(c,0xC1B9)==0&&rd(c,0xC1AB)==7&&rd(c,0xC1AC)==0xD8&&rd(c,0xC1AD)==4&&rd(c,0xC1AE)==0xD8&&
   rd(c,0xC1BC)==0&&rd(c,0xC1BD)==4&&rd(c,0xC1BF)==1&&rd(c,0xFF9D)==0xA5&&rd(c,0xC1BA)==0x5A,
   "Blocking controls2 3 newline15 null callback byte repeat wrap completes",remaining);
 }
 const unsigned glyphs[]={16,127,253},counts[]={0,1,106};
 for(unsigned index=0;index<4;index++)for(unsigned gi=0;gi<3;gi++)for(unsigned ci=0;ci<3;ci++)for(unsigned plane=0;plane<2;plane++){
  unsigned glyph=glyphs[gi],count=counts[ci],src=0x3F00+glyph*16,dst=0x96B0-count*16,font[16];
  wr(c,0xFF40,0);wr(c,0x27FF,2);wr(c,0x2800,0);for(unsigned i=0;i<16;i++)font[i]=rd(c,src+i);
  wr(c,0x27FF,0x0F);wr(c,0x2800,0);wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);unsigned restored[8];for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x4000+i);
  for(unsigned p=0;p<2;p++){wr(c,0xFF4F,p);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);cpu->a=index;cpu->c=0;cpu->de=0x5268;call(c,0x1E3);
  unsigned tileAddress=0x9800+offsets[records[index][1]+2]+records[index][0]+1;
  wr(c,0xC1B9,0);wr(c,0xC1BF,1);wr(c,0xC1B1,0x23);wr(c,0xC1AF,plane);wr(c,0xC1C2,count);wr(c,0xD800,glyph);wr(c,0xD801,0);
  cpu->bc=0;cpu->hl=0xD800;wr(c,0xFF40,0x91);call(c,0x1EF);
  struct GB *g=c->board;bool exact=rd(c,0xC1B8)==0&&rd(c,0xC1B9)==0&&rd(c,0xC1AB)==2&&rd(c,0xC1AC)==0xD8&&
   rd(c,0xC1BC)==1&&rd(c,0xC1BD)==0&&rd(c,0xC1C2)==count+1&&rd(c,0xC1C3)==0x6B-count&&rd(c,0xC113)==0x0F&&rd(c,0xC114)==0&&
   (rd(c,0xFF4F)&1)==plane&&g->memory.hdmaRemaining==0;
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==restored[i];wr(c,0xFF40,0);
  for(unsigned p=0;p<2;p++){wr(c,0xFF4F,p);for(unsigned address=0x8000;address<0xA000;address++){
   unsigned value=0xA5;if(address==tileAddress)value=p?0x23:0x6B-count;if(p==1&&address>=dst&&address<dst+16)value=font[address-dst];
   exact&=rd(c,address)==value;
  }}
  require(exact,"Original text record blocking glyph terminator exact two VRAM planes LCDon",index*18+gi*6+ci*2+plane);
 }
 wr(c,0xFF40,0);
 }
 { /* Full original A0F entry/input exit chain; explicit fixture producers. */
 const unsigned modes[]={0,1,2,255};
 wr(c,0xFF40,0);wr(c,0x27FF,0x0F);wr(c,0x2800,0);call(c,0x09EB);
 for(unsigned m=0;m<4;m++)for(unsigned family=0;family<4;family++)for(unsigned plane=0;plane<2;plane++){
  unsigned mode=modes[m],length=(family==1||family==2),choice=family>=2,finalChoice=family==2;
  unsigned effective=mode&&!length?3:mode,pointer=mode?0x50E0:0x4F60,font[448],colors[64],restored[8];
  wr(c,0xFF40,0);wr(c,0x27FF,0x0F);wr(c,0x2800,0);wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);
  wr(c,0x37FF,5);wr(c,0x3800,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);
  for(unsigned i=0;i<448;i++)font[i]=rd(c,pointer+i);
  for(unsigned i=0;i<64;i++){unsigned p=(mode?0x52EC:0x4E20)+2*i;colors[i]=rd(c,p)|(rd(c,p+1)<<8);}
  for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x4000+i);
  for(unsigned p=0;p<2;p++)for(unsigned i=0;i<64;i++){wr(c,p?0xFF6A:0xFF68,i);wr(c,p?0xFF6B:0xFF69,0x19);}
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC765,mode);wr(c,0xC764,0xA5);wr(c,0xC74E,length?17:0);wr(c,0xC74F,0);
  wr(c,0xC1B8,0);wr(c,0xC1B9,0);wr(c,0xC1BA,0);wr(c,0xCF86,0);wr(c,0xC21F,0);wr(c,0xC220,0);c->setKeys(c,0);wr(c,0xFF96,0);wr(c,0xFF99,0);wr(c,0xFF97,0);wr(c,0xFF98,0);wr(c,0xFF8A,0);wr(c,0xFF8B,0);
  struct GB *g=c->board;wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;
  wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4000;wr(c,0xFF40,0x91);
  unsigned steps=0,loops=0,wakes=0,fadeWakes=0,records=0;bool fontSeen=false;
  while((cpu->pc!=0xC100||cpu->executionState!=SM83_CORE_FETCH)&&steps++<2000000){
   if(cpu->executionState==SM83_CORE_FETCH){
    if(cpu->pc==0x4031){require(cpu->hl==pointer&&rd(c,0xC765)==effective,"Entry original font source selected before mode3 fallback",m*8+family*2+plane);}
    if(cpu->pc==0x4034){wr(c,0xFF40,0);bool exact=(rd(c,0xFF4F)&1)==0;wr(c,0xFF4F,1);
     for(unsigned i=0;i<288;i++)exact&=rd(c,0x96C0+i)==font[i];for(unsigned i=0;i<160;i++)exact&=rd(c,0x8760+i)==font[288+i];wr(c,0xFF4F,0);wr(c,0xFF40,0x91);
     require(exact,"Entry original consecutive font copies exact448 bytes on plane1",m*8+family*2+plane);fontSeen=true;
    }
    if(cpu->pc==0x403B||cpu->pc==0x4049||cpu->pc==0x405C){unsigned expected=records==0?0:records==1?1+(effective&1):3;
     require(cpu->a==expected&&cpu->c==0&&cpu->de==0x5268,"Entry actual indexed preparation record order",m*8+family*2+plane);records++;
    }
    if(cpu->pc==0x4077){loops++;
     if(loops==1){require(rd(c,0xC76C)==length&&rd(c,0xC76D)==0&&rd(c,0xC76A)==(mode?2:0)&&rd(c,0xC772)==1&&rd(c,0xC21F)==8&&rd(c,0xC220)==0,
       "Entry complete setup grid redraw indicator subtract transition precedes loop",m*8+family*2+plane);
      wr(c,0xC766,choice?8:6);wr(c,0xC767,4);c->setKeys(c,1);
     }else if(family==3&&loops==2){require(rd(c,0xC772)==1&&rd(c,0xC764)==1&&rd(c,0xC74E)==0,
       "Entry empty list choice1 rejected by original input before fixture selects choice0",m*8+family*2+plane);wr(c,0xC766,6);c->setKeys(c,0);}
     else if(family==3&&loops==3){require(rd(c,0xFF96)==0&&rd(c,0xFF97)==0,"Entry actual input poll sampled release before second press",m*8+family*2+plane);c->setKeys(c,1);}
    }
    if(cpu->pc==0x47D5){wakes++;unsigned caller=rd(c,cpu->sp)|(rd(c,cpu->sp+1)<<8);bool inFade=caller==0x47C2;if(inFade){fadeWakes++;if(rd(c,0xC220)!=(fadeWakes<8?8-fadeWakes:0)||rd(c,0xCF86)!=2)fprintf(stderr,"Entry fade wake=%u add=%u sub=%u busy=%u PC=%04X SP=%04X\n",fadeWakes,rd(c,0xC220),rd(c,0xC21F),rd(c,0xCF86),cpu->pc,cpu->sp);require(rd(c,0xC220)==(fadeWakes<8?8-fadeWakes:0)&&rd(c,0xCF86)==2,
      "Entry input starts actual countdown and completes eight fade ticks",m*8+family*2+plane);if(fadeWakes==8)wr(c,0xCF86,0);}
     g->memory.ime=false;require((caller==0x47C2||caller==0x409A)&&wakeSyntheticHalt(c,true),"Entry original HALT receives scheduled fixture wake without IRQ handler",m*8+family*2+plane);continue;
    }
   }
   c->step(c);
  }
  bool exact=cpu->pc==0xC100&&cpu->sp==0xD000&&cpu->a==finalChoice&&rd(c,0xC764)==finalChoice&&rd(c,0xC765)==effective&&
   rd(c,0xC772)==0&&rd(c,0xC21F)==(family==3?4:6)&&rd(c,0xC220)==0&&rd(c,0xCF86)==0&&rd(c,0xC74E)==(length?17:0)&&rd(c,0xC74F)==0&&fontSeen&&records==2+(effective&1)&&
   fadeWakes==8&&wakes==9+2*(family==3)&&loops==2+2*(family==3)&&rd(c,0xFF8A)==0&&rd(c,0xFF8B)==loops&&g->memory.ime&&
   rd(c,0xC67F)==0xD9&&rd(c,0xC682)==0xD9&&rd(c,0xFF8E)==0&&rd(c,0xFF8F)==0&&rd(c,0xFF92)==0&&rd(c,0xFF93)==0&&rd(c,0xC221)==1&&g->memory.hdmaRemaining==0&&
   rd(c,0xC113)==0x0F&&rd(c,0xC114)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0;
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==restored[i];
  for(unsigned i=0;i<64;i++){unsigned packed=0;for(unsigned channel=0;channel<3;channel++){unsigned component=(colors[i]>>(5*channel))&31,delta=(31-component)*256,word=0xF800-delta,index=i*3+channel;
   exact&=rd(c,0xC2A2+2*index)==(word&255)&&rd(c,0xC2A3+2*index)==word>>8&&rd(c,0xC422+2*index)==(delta&255)&&rd(c,0xC423+2*index)==delta>>8;packed|=((word>>11)&31)<<(5*channel);}
   exact&=rd(c,0xC222+2*i)==(packed&255)&&rd(c,0xC223+2*i)==packed>>8;
  }
  wr(c,0xFF40,0);for(unsigned p=0;p<2;p++)for(unsigned i=0;i<64;i++){wr(c,p?0xFF6A:0xFF68,i);exact&=rd(c,p?0xFF6B:0xFF69)==0x19;}
  if(!exact)fprintf(stderr,"Entry end mode=%u family=%u loops=%u wakes=%u fade=%u PC=%04X A=%u state=%u flags=%u ticks=%u records=%u IME=%u\n",mode,family,loops,wakes,fadeWakes,cpu->pc,cpu->a,rd(c,0xC772),rd(c,0xFF8B),rd(c,0xC220),records,g->memory.ime);
  require(exact,"Complete original entry returns choice clears callbacks and preserves list after forced frame/audio producers",m*8+family*2+plane);
 }
 c->setKeys(c,0);wr(c,0xFF40,0);wr(c,0xFF97,0);wr(c,0xFF98,0);
 }
 { /* Exhaustive polling transitions and bounded held/release traces. */
 struct GB *g=c->board;bool savedPolicy=g->allowOpposingDirections;wr(c,0xFF40,0);
 for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
 for(unsigned policy=0;policy<2;policy++){
  for(unsigned keys=0;keys<256;keys++)for(unsigned previous=0;previous<256;previous++){
   unsigned masked=sampledKeys(keys,policy)&0xF3;struct JoypadState old={previous,masked^1,(previous*73+keys)&255};
   probeJoypad(c,keys,policy,old,0x5A,false,policy*65536+keys*256+previous);
  }
  for(unsigned keys=0;keys<256;keys++)for(unsigned previousRepeat=0;previousRepeat<256;previousRepeat++){
   struct JoypadState old={(previousRepeat*19+keys)&255,previousRepeat,(previousRepeat*73+keys)&255};
   probeJoypad(c,keys,policy,old,0x5A,false,policy*65536+keys*256+previousRepeat);
  }
  for(unsigned keys=0;keys<256;keys++)for(unsigned counter=0;counter<256;counter++){
   unsigned sample=sampledKeys(keys,policy);struct JoypadState old={sample,sample&0xF3,counter};
   probeJoypad(c,keys,policy,old,0x5A,false,policy*65536+keys*256+counter);
  }
  for(unsigned frame=0;frame<256;frame++){
   unsigned keys=(frame*73)&255;struct JoypadState old={(frame*19)&255,frame^0xA5,(frame*41)&255};
   probeJoypad(c,keys,policy,old,frame,true,policy*256+frame);
  }
  for(unsigned keys=0;keys<256;keys++){
   struct JoypadState old={0,0,0};unsigned frame=0xF0;
   for(unsigned step=0;step<96;step++){unsigned current=step<48?keys:step<64?0:keys^1;
    old=probeJoypad(c,current,policy,old,frame,true,policy*24576+keys*96+step);frame=(frame+1)&255;
   }
  }
 }
 bool untouched=true;for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)untouched&=rd(c,0x8000+i)==0xA5;}
 require(untouched,"Whole VRAM remains untouched across exhaustive polling group",0);g->allowOpposingDirections=savedPolicy;c->setKeys(c,0);
 }
 { /* Resident selector/text plane/setters/font copies, complete bounded calls. */
 wr(c,0xFF40,0);wr(c,0xFF70,1);
 for(unsigned index=0;index<256;index++)for(unsigned flags=0;flags<16;flags++){
  cpu->a=index;cpu->f.packed=flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;wr(c,0xC1AF,0xA5);call(c,0x27F);
  unsigned selector=index<16?rd(c,0x3CD8+index):index-16;
  require(cpu->de==((index<16?0:8)<<8|selector)&&cpu->hl==(index<16?0x3CD8+index:0x9ABC)&&cpu->bc==0xBEEF&&
   cpu->a==(index<16?0x3C:index-16)&&cpu->f.packed==(index<16?0:index==16?0xC0:0x40)&&rd(c,0xC1AF)==0xA5,
   "Original selector all index flags table or flash arithmetic no mapper selection",index*16+flags);
 }
 const unsigned setters[]={0x1D7,0x1DA,0x1DD},fields[]={0xC1C0,0xC219,0xC1AB};
 for(unsigned kind=0;kind<3;kind++)for(unsigned value=0;value<65536;value++){
  unsigned field=fields[kind],a=(value*73+1)&255,flags=(value&15)<<4;
  wr(c,field-1,0xA5);wr(c,field+2,0x5A);cpu->a=a;cpu->f.packed=flags;cpu->bc=0xBEEF;cpu->de=value;cpu->hl=0x9ABC;call(c,setters[kind]);
  require(rd(c,field)==(value&255)&&rd(c,field+1)==value>>8&&rd(c,field-1)==0xA5&&rd(c,field+2)==0x5A&&
   cpu->a==a&&cpu->f.packed==flags&&cpu->bc==0xBEEF&&cpu->de==value&&cpu->hl==field+1,
   "Original text DE setters full word domain preserve AF BC DE and adjacent guards",kind*65536+value);
 }
 for(unsigned mapping=0;mapping<2;mapping++)for(unsigned plane=0;plane<256;plane++)for(unsigned prior=0;prior<2;prior++)for(unsigned lcd=0;lcd<2;lcd++){
  unsigned selector=mapping?0x16:0x0F,source[32],restored[8];wr(c,0xFF40,0);wr(c,0x27FF,selector);wr(c,0x2800,0);wr(c,0xFFAB,selector);wr(c,0xFFAC,0);
  for(unsigned i=0;i<32;i++)source[i]=rd(c,0x4EE0+i);for(unsigned i=0;i<8;i++)restored[i]=rd(c,0x4000+i);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,prior);wr(c,0xC21C,mapping?0x0F:0x16);wr(c,0xC21D,0);wr(c,0xC1B8,0x5A);wr(c,0xC1C0,0xCC);wr(c,0xC1C1,0xCC);wr(c,0xC219,0xCC);wr(c,0xC21A,0xCC);wr(c,0xC1C2,0xCC);wr(c,0xC1BF,0xCC);
  cpu->a=plane;if(lcd)wr(c,0xFF40,0x91);call(c,0x1D4);
  struct GB *g=c->board;bool exact=rd(c,0xC1AF)==plane&&rd(c,0xC1C0)==0&&rd(c,0xC1C1)==0&&rd(c,0xC219)==0&&rd(c,0xC21A)==0&&rd(c,0xC1C2)==0&&rd(c,0xC1BF)==0&&
   rd(c,0xC1B5)==0&&rd(c,0xC1B6)==0x98&&rd(c,0xC1A3)==(plane?15:7)&&rd(c,0xC1B0)==(plane?8:0)&&rd(c,0xC1B1)==(plane?9:1)&&rd(c,0xC1B2)==(plane?10:2)&&rd(c,0xC1B7)==(plane?8:0)&&rd(c,0xC1B8)==0x5A&&
   cpu->a==prior&&cpu->f.packed==(prior?0x20:0xA0)&&cpu->bc==0&&cpu->de==0x9800&&cpu->hl==0x4F00&&(rd(c,0xFF4F)&1)==prior&&g->memory.ime&&rd(c,0xFFAB)==selector&&rd(c,0xC21C)==(mapping?0x0F:0x16);
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==restored[i];wr(c,0xFF40,0);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){unsigned expected=(bank==(plane&1)&&i>=0x17E0&&i<0x1800)?source[i-0x17E0]:0xA5;exact&=rd(c,0x8000+i)==expected;}}
  require(exact,"Original text plane all raw A current source ignores C21C attrs full VRAM LCDoff on",mapping*1024+plane*4+prior*2+lcd);
 }
 const unsigned pointers[]={0x4F60,0x50E0,0x6800};
 for(unsigned resource=0;resource<3;resource++)for(unsigned plane=0;plane<256;plane++)for(unsigned prior=0;prior<2;prior++)for(unsigned lcd=0;lcd<2;lcd++){
  unsigned pointer=pointers[resource],selector=resource==2?0x5A:0x0F,source[448],aBytes[8],bBytes[8];wr(c,0xFF40,0);
  wr(c,resource==2?0x37FF:0x27FF,selector);wr(c,resource==2?0x3800:0x2800,0);for(unsigned i=0;i<448;i++)source[i]=rd(c,pointer+i);
  wr(c,0x27FF,0x16);wr(c,0x2800,0);wr(c,0xFFAB,0x16);wr(c,0xFFAC,0);wr(c,0x37FF,5);wr(c,0x3800,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);wr(c,0xC113,0x16);wr(c,0xC114,0);wr(c,0xC115,5);wr(c,0xC116,0);
  for(unsigned i=0;i<8;i++){aBytes[i]=rd(c,0x4000+i);bBytes[i]=rd(c,0x6000+i);}
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,prior);wr(c,0xC1AF,plane);wr(c,0xC21C,selector);wr(c,0xC21D,0);wr(c,0xC1B8,0x5A);cpu->hl=pointer;if(lcd)wr(c,0xFF40,0x91);call(c,0x1E0);
  struct GB *g=c->board;bool exact=cpu->a==prior&&cpu->f.packed==(prior?0x20:0xA0)&&cpu->bc==0&&cpu->de==0x8800&&cpu->hl==pointer+448&&(rd(c,0xFF4F)&1)==prior&&g->memory.ime&&
   rd(c,0xC1AF)==plane&&rd(c,0xC1B8)==0x5A&&rd(c,0xFFAB)==0x16&&rd(c,0xFFAC)==0&&rd(c,0xFFAD)==5&&rd(c,0xFFAE)==0&&
   rd(c,0xC113)==0x16&&rd(c,0xC114)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0;
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==aBytes[i]&&rd(c,0x6000+i)==bBytes[i];wr(c,0xFF40,0);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){unsigned value=0xA5;
   if(bank==(plane&1)){if(i>=0x16C0&&i<0x17E0)value=source[i-0x16C0];if(i>=0x760&&i<0x800)value=source[288+i-0x760];}exact&=rd(c,0x8000+i)==value;}}
  require(exact,"Original text font banked A B resources all raw plane bytes both full VRAM LCDoff on",resource*1024+plane*4+prior*2+lcd);
 }
 }
 { /* Actual original KEY1/STOP transitions; no core speed-field mutation. */
 struct GB *g=c->board;wr(c,0xFF40,0);wr(c,0xFF07,0);wr(c,0xFF02,0);c->setKeys(c,0);
 for(unsigned initial=0;initial<2;initial++)for(unsigned target=0;target<2;target++)
 for(unsigned ie=0;ie<256;ie++)for(unsigned flags=0;flags<16;flags++){
  call(c,initial?0x270:0x273);
  require(g->doubleSpeed==initial,"Original helper establishes initial speed",initial);
  wr(c,0xFFFF,ie);wr(c,0xFF0F,0x15);wr(c,0xFF00,0x30);wr(c,0xC1B8,0x5A);
  g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->a=0x5A;cpu->f.packed=flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;
  cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=target?0x270:0x273;
  unsigned steps=0;while(cpu->pc!=0xC100&&steps++<1000)c->step(c);
  bool changed=initial!=target;unsigned expectedFlags=(initial?0x20:0xA0)|((flags&1)?0x10:0);
  require(cpu->pc==0xC100&&cpu->sp==0xD000&&g->doubleSpeed==target&&cpu->tMultiplier==2-target&&
   rd(c,0xFF4D)==(target?0xFE:0x7E)&&rd(c,0xFFFF)==ie&&(rd(c,0xFF0F)&31)==(changed?0:0x15)&&
   rd(c,0xFF00)==(changed?0xCF:0xFF)&&cpu->a==(changed?ie:initial?0xFE:0x7E)&&cpu->f.packed==expectedFlags&&
   cpu->bc==0xBEEF&&cpu->de==0x5678&&cpu->hl==0x9ABC&&rd(c,0xC1B8)==0x5A&&!g->memory.ime,
   "Original speed helpers both modes full IE flags preserved registers and early return",((initial*2+target)*256+ie)*16+flags);
 }
 call(c,0x273);
 }
 { /* Disposable flash RET targets: original dispatcher, no flash commands/save. */
 struct GB *g=c->board;
 require(g->memory.sram&&g->sramSize>=GB_SIZE_MBC6_FLASH_STORAGE,"Flash callback disposable backing available",0);
 uint8_t *flash=g->memory.sram+g->sramSize-GB_SIZE_MBC6_FLASH_STORAGE;
 uint8_t *before=malloc(GB_SIZE_MBC6_FLASH_STORAGE);if(!before)exit(11);memcpy(before,flash,GB_SIZE_MBC6_FLASH_STORAGE);
 const unsigned targets[]={0x4100,0x5FFF,0x6000,0x6100};
 wr(c,0xFF40,0);wr(c,0xFF07,0);wr(c,0xFF02,0);wr(c,0xFF70,1);
 for(unsigned kind=0;kind<4;kind++)for(unsigned selector=0;selector<128;selector++)
 for(unsigned types=0;types<4;types++)for(unsigned guarded=0;guarded<2;guarded++)for(unsigned flags=0;flags<16;flags++){
  unsigned target=targets[kind],window=target>=0x6000,offset=selector*8192+(target&8191),saved=flash[offset];flash[offset]=0xC9;
  unsigned aType=(types&1)?8:0,bType=(types&2)?8:0,aSelector=aType?3:0x16,bSelector=bType?5:0x0F;
  wr(c,0x1000,1);wr(c,0x0C00,1);wr(c,0x1000,0);
  wr(c,0x27FF,aSelector);wr(c,0x2800,aType);wr(c,0x37FF,bSelector);wr(c,0x3800,bType);
  wr(c,0xFFAB,aSelector);wr(c,0xFFAC,aType);wr(c,0xFFAD,bSelector);wr(c,0xFFAE,bType);
  wr(c,0xC113,aSelector);wr(c,0xC114,aType);wr(c,0xC115,bSelector);wr(c,0xC116,bType);
  unsigned aBytes[8],bBytes[8];for(unsigned i=0;i<8;i++){aBytes[i]=rd(c,0x4000+i);bBytes[i]=rd(c,0x6000+i);}
  if(!guarded){wr(c,0x1000,1);wr(c,0x0C00,0);wr(c,0x1000,0);}
  wr(c,0xCEE9,guarded);wr(c,0xC66C,0xA5);wr(c,0xC66F,0x5A);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->a=selector;cpu->f.packed=flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=target;
  cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x26A;
  unsigned steps=0;while(cpu->pc!=target&&steps++<1000)c->step(c);
  unsigned tail=window?0x2532:0x24EA,priorSelector=window?bSelector:aSelector,priorType=window?bType:aType;
  unsigned cpFlags=kind==0?0x50:kind==1?0x50:kind==2?0xC0:0x40;
  require(cpu->pc==target&&cpu->sp==0xCFFC&&rd(c,0xCFFC)==(tail&255)&&rd(c,0xCFFD)==tail>>8&&
   rd(c,target)==0xC9&&cpu->a==8&&cpu->f.packed==cpFlags&&cpu->bc==(selector<<8|0xEF)&&cpu->de==tail&&cpu->hl==target&&
   rd(c,0xC66D)==priorSelector&&rd(c,0xC66E)==priorType&&rd(c,0xC66C)==0xA5&&rd(c,0xC66F)==0x5A&&
   rd(c,0xFFAB)==(window?bSelector:selector)&&rd(c,0xFFAC)==(window?bType:8)&&
   rd(c,0xFFAD)==(window?selector:bSelector)&&rd(c,0xFFAE)==(window?8:bType)&&
   rd(c,0xC113)==(window?aSelector:selector)&&rd(c,0xC114)==(window?aType:8)&&
   rd(c,0xC115)==(window?selector:bSelector)&&rd(c,0xC116)==(window?8:bType)&&g->memory.mbcState.mbc6.flashEnable,
   "Original flash callback prefix reaches mapped RET target with asymmetric B HRAM mirrors",kind*128+selector);
  steps=0;while(cpu->pc!=0xC100&&steps++<1000)c->step(c);
  bool exact=cpu->pc==0xC100&&cpu->sp==0xD000&&cpu->a==0&&cpu->f.packed==0x80&&cpu->bc==(selector<<8|0xEF)&&cpu->de==tail&&cpu->hl==target&&
   rd(c,0xFFAB)==(window?bSelector:aSelector)&&rd(c,0xFFAC)==(window?bType:aType)&&rd(c,0xFFAD)==bSelector&&rd(c,0xFFAE)==bType&&
   rd(c,0xC113)==aSelector&&rd(c,0xC114)==aType&&rd(c,0xC115)==bSelector&&rd(c,0xC116)==bType&&rd(c,0xCEE9)==guarded&&
   rd(c,0xC66C)==0xA5&&rd(c,0xC66F)==0x5A&&g->memory.ime&&!g->memory.mbcState.mbc6.flashEnable&&
   !g->memory.mbcState.mbc6.flashWriteEnable&&!g->memory.mbcState.mbc6.flashOperationActive;
  for(unsigned i=0;i<8;i++){exact&=rd(c,0x4000+i)==(aType?0xFF:aBytes[i]);exact&=rd(c,0x6000+i)==(bType?0xFF:bBytes[i]);}
  require(exact,"Original flash callback complete RET tail restores actual windows and disables reads",kind*128+selector);
  flash[offset]=saved;
 }
 /* Negative prerequisite: software bit0 can skip enabling reads. Stop before target. */
 for(unsigned window=0;window<2;window++){
  wr(c,0x1000,1);wr(c,0x0C00,0);wr(c,0x1000,0);wr(c,0xCEE9,1);
  wr(c,0x27FF,0x16);wr(c,0x2800,0);wr(c,0xFFAB,0x16);wr(c,0xFFAC,0);
  wr(c,0x37FF,0x0F);wr(c,0x3800,0);wr(c,0xFFAD,0x0F);wr(c,0xFFAE,0);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->a=7;cpu->hl=window?0x6100:0x4100;unsigned target=cpu->hl;
  cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x26A;
  unsigned steps=0;while(cpu->pc!=target&&steps++<1000)c->step(c);
  require(cpu->pc==target&&rd(c,target)==0xFF&&!g->memory.mbcState.mbc6.flashEnable&&
   !g->memory.mbcState.mbc6.flashWriteEnable&&rd(c,0xCEE9)==1,
   "Negative flash callback prerequisite bit0 skips read enable stop before invalid target",window);
  call(c,0x1359); /* Forced cleanup, not completion of the invalid callback. */
 }
 require(memcmp(before,flash,GB_SIZE_MBC6_FLASH_STORAGE)==0,"Whole disposable flash backing restored including extra metadata",0);free(before);
 }
 { /* Selection initializer: two exhaustive byte axes and full pointer domain. */
 const unsigned divisors[]={0,1,2,3,7,16,255};unsigned index=0;
 wr(c,0xFF40,0);wr(c,0xFF70,1);
 for(unsigned n=0;n<7;n++)for(unsigned count=0;count<256;count++)for(unsigned stride=0;stride<256;stride++)
  probeSelectionFields(c,0xBEEF,0x37,divisors[n],count,stride,((count^stride)&15)<<4,index++);
 for(unsigned n=0;n<7;n++)for(unsigned count=0;count<256;count++)for(unsigned columns=0;columns<256;columns++)
  probeSelectionFields(c,0xBEEF,0x37,columns,count,divisors[n],((count^columns)&15)<<4,index++);
 for(unsigned pointer=0;pointer<65536;pointer++)probeSelectionFields(c,pointer,0x37,4,43,3,(pointer&15)<<4,index++);
 for(unsigned b=0;b<256;b++)for(unsigned flags=0;flags<16;flags++)probeSelectionFields(c,0xBEEF,b,4,43,3,flags<<4,index++);
 }
 { /* Original selection draw and activation, bounded empty-record corpus. */
 const unsigned limits[]={0,1,2,3,5,9,16};unsigned index=0;
 for(unsigned rows=1;rows<=3;rows++)for(unsigned columns=1;columns<=3;columns++)for(unsigned page=0;page<3;page++)
 for(unsigned n=0;n<7;n++)for(unsigned prior=0;prior<2;prior++)for(unsigned activate=0;activate<2;activate++)for(unsigned f=0;f<2;f++){
  unsigned limit=limits[n],visited=0,remaining=0,lastCol=0;bool aborted=false;
  for(unsigned row=0;row<rows&&!aborted;row++)for(unsigned col=0;col<columns;col++){
   unsigned first=(page+1)*row,entry=page*rows*columns+row*columns+col;
   if(((limit+1)&255)<first||((limit-1)&255)<entry){remaining=rows-row;aborted=true;break;}
   visited++;lastCol=2*col;
  }
  wr(c,0xFF40,0);wr(c,0xFF70,1);for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,prior);wr(c,0xC1A3,0x23);wr(c,0xC1A4,1);wr(c,0xC1A7,2);wr(c,0xC1A8,8);wr(c,0xC1A9,4);wr(c,0xC1AA,1);
  wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1B8,0x5A);wr(c,0xC1B9,0);wr(c,0xC1BC,0xA5);wr(c,0xC1BD,0x3C);wr(c,0xC1AB,0xA5);wr(c,0xC1AC,0x5A);wr(c,0xC1C2,0x3C);
  for(unsigned i=0;i<256;i++)wr(c,0xD800+i,0);wr(c,0xD7FF,0x33);wr(c,0xD900,0x5A);
  wr(c,0xC20A,0);wr(c,0xC20B,0xD8);wr(c,0xC20D,0);wr(c,0xC20E,rows);wr(c,0xC20F,limit);wr(c,0xC210,columns);wr(c,0xC212,page);wr(c,0xC213,0xA5);
  unsigned flags=f?0xF0:0x10;cpu->a=0x5A;cpu->f.packed=flags;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;call(c,activate?0x1F5:0x30BC);
  unsigned end=0xD800+page*rows*columns+visited;
  bool exact=cpu->a==(activate?1:0x5A)&&cpu->f.packed==flags&&cpu->bc==0xBEEF&&cpu->de==0x5678&&cpu->hl==0x9ABC&&
   rd(c,0xC213)==(activate?1:0xA5)&&rd(c,0xC1BD)==remaining&&rd(c,0xC1BC)==(visited?lastCol:0)&&rd(c,0xC1C2)==0x3C&&
   rd(c,0xC1AB)==(visited?(end&255):0xA5)&&rd(c,0xC1AC)==(visited?end>>8:0x5A)&&rd(c,0xC1B8)==(visited?0:0x5A)&&
   rd(c,0xD7FF)==0x33&&rd(c,0xD900)==0x5A&&(rd(c,0xFF4F)&1)==prior;
  if(!exact)fprintf(stderr,"Selection draw rows=%u cols=%u page=%u limit=%u visits=%u remaining=%u actualCursor=%u,%u ptr=%02X%02X\n",rows,columns,page,limit,visited,remaining,rd(c,0xC1BC),rd(c,0xC1BD),rd(c,0xC1AC),rd(c,0xC1AB));
  require(exact,"Original selection draw empty records limits abort state and AF BC DE HL",index);
  for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++){
   bool filled=i>=0x1821&&i<0x1921&&((i-0x1821)%32)<8;exact&=rd(c,0x8000+i)==(filled?(plane?0x23:0x70):0xA5);
  }}
  require(exact,"Original selection draw complete two-plane rectangle with empty text",index++);
 }
 }
 { /* Actual glyph uploads and a skipped02-terminated continuation record. */
 const unsigned glyphs[]={16,127,253};unsigned index=0;
 for(unsigned gi=0;gi<3;gi++)for(unsigned skip=0;skip<2;skip++)for(unsigned plane=0;plane<2;plane++)for(unsigned activate=0;activate<2;activate++){
  unsigned glyph=glyphs[gi],font[16];wr(c,0xFF40,0);wr(c,0xFF70,1);wr(c,0x27FF,2);wr(c,0x2800,0);
  for(unsigned i=0;i<16;i++)font[i]=rd(c,0x3F00+glyph*16+i);
  wr(c,0x27FF,0x0F);wr(c,0x2800,0);wr(c,0xFFAB,0x0F);wr(c,0xFFAC,0);wr(c,0xC113,0x0F);wr(c,0xC114,0);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xC1AF,plane);wr(c,0xC1A3,0x23);wr(c,0xC1A4,1);wr(c,0xC1A7,2);wr(c,0xC1A8,8);wr(c,0xC1A9,4);wr(c,0xC1AA,1);
  wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1B9,0);wr(c,0xC1BA,0);wr(c,0xC1BF,1);wr(c,0xC1B1,0x23);wr(c,0xC1C2,0);
  const unsigned blob[]={2,0,0,glyph,0};if(skip){for(unsigned i=0;i<5;i++)wr(c,0xD800+i,blob[i]);}else{wr(c,0xD800,glyph);wr(c,0xD801,0);}wr(c,0xD7FF,0x33);
  wr(c,0xC20A,0);wr(c,0xC20B,0xD8);wr(c,0xC20D,0);wr(c,0xC20E,1);wr(c,0xC20F,skip?2:1);wr(c,0xC210,1);wr(c,0xC212,skip);wr(c,0xC213,0xA5);
  cpu->a=0x5A;cpu->f.packed=0xF0;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;wr(c,0xFF40,0x91);call(c,activate?0x1F5:0x30BC);
  bool exact=cpu->a==(activate?1:0x5A)&&cpu->f.packed==0xF0&&cpu->bc==0xBEEF&&cpu->de==0x5678&&cpu->hl==0x9ABC&&
   rd(c,0xC1AB)==(skip?5:2)&&rd(c,0xC1AC)==0xD8&&rd(c,0xC1BC)==1&&rd(c,0xC1BD)==0&&rd(c,0xC1C2)==1&&rd(c,0xC1C3)==0x6B&&
   rd(c,0xC213)==(activate?1:0xA5)&&rd(c,0xC113)==0x0F&&rd(c,0xC114)==0&&(rd(c,0xFF4F)&1)==plane&&rd(c,0xD7FF)==0x33;
  require(exact,"Original selection draw actual glyph and skipped02 continuation completes",index);
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){
   bool filled=i>=0x1821&&i<0x1921&&((i-0x1821)%32)<8;unsigned expected=filled?(bank?0x23:0x70):0xA5;
   if(i==0x1841)expected=bank?0x23:0x6B;if(bank==1&&i>=0x16B0&&i<0x16C0)expected=font[i-0x16B0];
   unsigned actual=rd(c,0x8000+i);if(actual!=expected&&exact)fprintf(stderr,"Selection glyph VRAM bank=%u offset=%04X actual=%02X expected=%02X glyph=%u skip=%u\n",bank,i,actual,expected,glyph,skip);exact&=actual==expected;
  }}require(exact,"Original selection draw whole VRAM glyph font upload original bytes",index++);
 }
 }
 { /* Full original input, sound requests, redraw, cursors and callback bodies. */
 const struct SelectionModel states[]={
  {1,1,1,1,0,0,0,1},{3,1,2,2,0,0,0,5},{3,1,2,2,0,2,0,5},{3,2,2,2,1,0,0,8},
  {3,2,2,2,1,1,1,8},{2,3,2,1,0,1,2,6},{2,2,1,3,1,0,0,9},{2,2,1,3,2,0,1,9}};
 unsigned index=0;const unsigned capacities[]={0,15,16},frames[]={0,8,16,24};
 for(unsigned state=0;state<8;state++)for(unsigned mode=0;mode<2;mode++)for(unsigned repeat=0;repeat<256;repeat++)for(unsigned edge=0;edge<2;edge++)
 for(unsigned f=0;f<4;f++)for(unsigned cap=0;cap<3;cap++)probeSelectionInput(c,states[state],repeat,edge,mode*2,frames[f],capacities[cap],state&1,index++);
 for(unsigned state=0;state<2;state++)for(unsigned mode=0;mode<2;mode++)for(unsigned frame=0;frame<256;frame++)for(unsigned cap=0;cap<3;cap++)
  probeSelectionInput(c,states[state?6:5],0,0,mode*2,frame,capacities[cap],true,index++);
 struct SelectionModel fixed={2,2,2,2,0,0,0,8};
 for(unsigned mode=0;mode<2;mode++)for(unsigned repeat=0;repeat<256;repeat++)for(unsigned edge=0;edge<256;edge++)probeSelectionInput(c,fixed,repeat,edge,mode*2,16,0,true,index++);
 for(unsigned page=0;page<256;page++)for(unsigned row=0;row<256;row++){
  struct SelectionModel state={7,13,1,3,page,row,(page+row)&255,255};probeSelectionInput(c,state,0,1,(page&1)*2,0,0,false,index++);
 }
 }
 { /* Inactive guard and full raw mode-index dispatch prefixes. */
 struct GB *g=c->board;const unsigned modes[]={0,1,2,255};
 for(unsigned a=0;a<256;a++)for(unsigned flags=0;flags<16;flags++)for(unsigned keys=0;keys<2;keys++){
  wr(c,0xC213,0);wr(c,0xC215,0xA5);wr(c,0xC216,0x3C);wr(c,0xC218,modes[a&3]);wr(c,0xC1C4,0x5A);wr(c,0xFF98,keys?255:0);wr(c,0xFF97,keys?255:0);
  cpu->a=a;cpu->f.packed=flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;call(c,0x1F8);
  require(cpu->a==0&&cpu->f.packed==0x80&&cpu->bc==0xBEEF&&cpu->de==0x5678&&cpu->hl==0x9ABC&&rd(c,0xC215)==0xA5&&rd(c,0xC216)==0x3C&&rd(c,0xC1C4)==0x5A,
   "Selection inactive guard full AF domain preserves BC DE HL and fields",a*32+flags*2+keys);
 }
 for(unsigned mode=0;mode<256;mode++){
  wr(c,0xC213,1);wr(c,0xC212,0);wr(c,0xC215,0);wr(c,0xC218,mode);wr(c,0xFF98,0);wr(c,0xFF97,0);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x1F8;
  unsigned steps=0;while(cpu->pc!=0x5F5&&steps++<1000)c->step(c);
  require(cpu->pc==0x5F5&&cpu->sp==0xCFFC,"Selection raw mode prefix reaches original table dispatcher",mode);
  unsigned offset=(mode*2)&255,target=rd(c,0x2AB9+offset)|(rd(c,0x2ABA+offset)<<8);
  for(unsigned instruction=0;instruction<10;instruction++)c->step(c);
  unsigned expectedFlags=(!offset?0x80:0); /* ADD HL,DE replaces H/C, retains Z. */
  if(!(cpu->pc==0x600&&cpu->sp==0xCFFE&&cpu->hl==target&&cpu->de==target&&cpu->a==offset&&cpu->f.packed==expectedFlags))fprintf(stderr,"Raw mode=%u pc=%04X target=%04X SP=%04X HL=%04X DE=%04X A=%02X F=%02X expectedF=%02X\n",mode,cpu->pc,target,cpu->sp,cpu->hl,cpu->de,cpu->a,cpu->f.packed,expectedFlags);
  require(cpu->pc==0x600&&cpu->sp==0xCFFE&&cpu->hl==target&&cpu->de==target&&cpu->a==offset&&cpu->f.packed==expectedFlags,
   "Selection raw modes byte-wrapped index no range guard stop before JP HL",mode);
 }
 }
 { /* Original A12 caller initializes mode2 before the first external SYS0 call. */
 struct GB *g=c->board;wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned seed=0;seed<256;seed++)for(unsigned bank=0;bank<8;bank++)for(unsigned flags=0;flags<16;flags++){
  for(unsigned address=0xC5A2;address<=0xC5E3;address++)wr(c,address,(seed+address)&255);
  wr(c,0xC217,0x33);wr(c,0xC218,0xA5);wr(c,0xC219,0x5A);wr(c,0xFF70,bank);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->af=seed<<8|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4000;
  unsigned steps=0;while(cpu->pc!=0x404C&&steps++<1000)c->step(c);
  unsigned index=seed*128+bank*16+flags;
  require(cpu->pc==0x404C&&cpu->sp==0xCFFC&&rd(c,0xCFFC)==3&&rd(c,0xCFFD)==0x40,"A12 original entry calls initializer before SYS0 load prefix",index);
  bool exact=rd(c,0xC5A2)==((seed+0xC5A2)&255)&&rd(c,0xC5E3)==((seed+0xC5E3)&255);
  for(unsigned address=0xC5A3;address<=0xC5E2;address++)exact&=rd(c,address)==(address==0xC5C3?255:0);
  require(exact&&rd(c,0xC217)==0x33&&rd(c,0xC218)==2&&rd(c,0xC219)==0x5A&&(rd(c,0xFF70)&7)==2,"A12 exact64-byte clear guards mode2 and WRAM selector",index);
  require(cpu->af==0x0280&&cpu->bc==0&&cpu->de==0x5678&&cpu->hl==0xC5E3,"A12 initialization prefix complete registers",index);
 }
 }
 { /* A12 raw state dispatcher prefixes; no invalid indirect targets executed. */
 struct GB *g=c->board;wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned state=0;state<256;state++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5A3,state);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x413A;
  unsigned offset=(state*2)&255,target=rd(c,0x4150+offset)|(rd(c,0x4151+offset)<<8),steps=0,index=state*16+flags;
  while(cpu->pc!=0x414E&&steps++<100)c->step(c);
  require(cpu->pc==0x414E&&cpu->sp==0xCFFC&&rd(c,0xCFFC)==0x4F&&rd(c,0xCFFD)==0x41&&rd(c,0xCFFE)==0&&rd(c,0xCFFF)==0xC1,"A12 original dispatcher pushes414F return before JP HL",index);
  require(cpu->hl==target&&cpu->de==target&&cpu->bc==0xBEEF&&cpu->a==offset&&cpu->f.packed==(offset?0:0x80)&&rd(c,0xC5A3)==state,"A12 all raw states wrapped table target registers stop before indirect jump",index);
  if(!offset){for(unsigned i=0;i<3;i++)c->step(c);require(cpu->pc==0xC100&&cpu->sp==0xD000,"A12 state0 and128 actual no-op and two return chain",index);}
 }
 }
 { /* Actual HALT and flag wait tails; synthetic producer, never natural IRQ. */
 struct GB *g=c->board;wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned state=0;state<256;state++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5A3,state);wr(c,0xC5A9,0xA5);wr(c,0xFF8A,0);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x401B;unsigned index=state*16+flags;
  require(wakeSyntheticHalt(c,false),"A12 original HALT receives scheduled wake without setting frame flag",index);
  unsigned steps=0;while(cpu->pc!=0x401D&&steps++<10)c->step(c);
  require(cpu->pc==0x401D&&rd(c,0xFF8A)==0,"A12 HALT wake alone does not produce frame flag",index);
  for(unsigned i=0;i<12;i++)c->step(c);
  if(!(cpu->pc==0x401D&&cpu->af==0x00A0&&cpu->sp==0xCFFE))fprintf(stderr,"A12 wait PC=%04X AF=%04X SP=%04X phase=%u flag=%02X halted=%u\n",cpu->pc,cpu->af,cpu->sp,cpu->executionState,rd(c,0xFF8A),cpu->halted);
  require(cpu->pc==0x401D&&cpu->af==0x00A0&&cpu->sp==0xCFFE,"A12 original zero flag wait remains polling for four complete iterations",index);
  wr(c,0xFF8A,0x80);steps=0;unsigned target=state?0x4003:0x402D;
  while(cpu->pc!=target&&steps++<30)c->step(c);
  require(cpu->pc==target&&cpu->sp==0xCFFE&&cpu->a==state&&cpu->f.packed==(state?0x20:0xA0)&&cpu->bc==0xBEEF&&cpu->de==0x5678&&cpu->hl==0x9ABC&&rd(c,0xFF8A)==0&&rd(c,0xC5A3)==state&&rd(c,0xC5A9)==0xA5,
   "A12 frame flag consumed and all state bytes branch to loop or cleanup prefix",index);
 }
 }
 { /* Full A12 exit/cleanup using disposable in-memory existing SYS0 record. */
 struct GB *g=c->board;wr(c,0xFF40,0);wr(c,0xFF70,2);
 for(unsigned seed=0;seed<256;seed++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0x0000,0x0A);wr(c,0x0400,0);wr(c,0x0800,1);wr(c,0xFFAF,0);wr(c,0xFFB0,1);
  for(unsigned i=0;i<0x800;i++)wr(c,0xA000+i,0);
  wr(c,0xA002,0);wr(c,0xA003,0xA4);
  for(unsigned i=0;i<4;i++){wr(c,0xA004+i,rd(c,0x17B3+i));wr(c,0xA402+i,rd(c,0x17B3+i));}
  wr(c,0xA406,50);wr(c,0xA43B,0x5A);
  for(unsigned i=0;i<50;i++){wr(c,0xC700+i,(seed+i*13)&255);wr(c,0xA409+i,0xA5);}
  wr(c,0x27FF,0x12);wr(c,0x2800,0);wr(c,0xFFAB,0x12);wr(c,0xFFAC,0);wr(c,0xC113,0x12);wr(c,0xC114,0);
  wr(c,0x37FF,5);wr(c,0x3800,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);wr(c,0xC115,5);wr(c,0xC116,0);
  unsigned aBytes[8],bBytes[8];for(unsigned i=0;i<8;i++){aBytes[i]=rd(c,0x4000+i);bBytes[i]=rd(c,0x6000+i);}
  for(unsigned i=0;i<6;i++)wr(c,0xC67F+i,(seed+i)&255);
  wr(c,0xC67E,0x33);wr(c,0xC685,0x5A);wr(c,0xFF8E,0xAA);wr(c,0xFF8F,0xBB);wr(c,0xFF92,0xCC);wr(c,0xFF93,0xDD);wr(c,0xFF45,0x3F);
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;call(c,0x402D);unsigned index=seed*16+flags;
  bool exact=cpu->af==0x00A0&&cpu->de==0&&cpu->hl==0xC682&&g->memory.ime&&rd(c,0xFFFF)==0&&rd(c,0xFF45)==0&&!(rd(c,0xFF41)&0x40)&&rd(c,0xA409)==255;
  exact&=rd(c,0xC67F)==0xD9&&rd(c,0xC682)==0xD9&&rd(c,0xC67E)==0x33&&rd(c,0xC685)==0x5A;
  for(unsigned i=1;i<3;i++)exact&=rd(c,0xC67F+i)==((seed+i)&255)&&rd(c,0xC682+i)==((seed+3+i)&255);
  exact&=rd(c,0xFF8E)==0&&rd(c,0xFF8F)==0&&rd(c,0xFF92)==0&&rd(c,0xFF93)==0&&rd(c,0xC113)==0x12&&rd(c,0xC114)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0;
  for(unsigned i=0;i<8;i++)exact&=rd(c,0x4000+i)==aBytes[i]&&rd(c,0x6000+i)==bBytes[i];
  require(exact,"A12 complete original exit stores SYS0 disables SRAM clears callbacks retains stub operands and mapping",index);
  wr(c,0x0000,0x0A);wr(c,0x0400,0);wr(c,0x0800,1);unsigned sum=0;
  for(unsigned i=2;i<59;i++)sum+=rd(c,0xA400+i);
  exact=(rd(c,0xA400)|(rd(c,0xA401)<<8))==(sum&65535)&&rd(c,0xA43B)==0x5A;
  for(unsigned i=0;i<50;i++)exact&=rd(c,0xA409+i)==((seed+i*13)&255)&&rd(c,0xC700+i)==((seed+i*13)&255);
  require(exact,"A12 cleanup original50-byte SYS0 payload checksum and guard no disk save",index);
 }
 wr(c,0x0000,0);g->memory.ime=false;
 }
 { /* Raw A12 variant targets; valid variants traverse both real dispatchers. */
 struct GB *g=c->board;wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned variant=0;variant<256;variant++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5A8,variant);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4157;
  unsigned offset=(variant*2)&255,target=rd(c,0x416D+offset)|(rd(c,0x416E + offset)<<8),steps=0,index=variant*16+flags;
  while(cpu->pc!=0x416B&&steps++<100)c->step(c);
  require(cpu->pc==0x416B&&cpu->sp==0xCFFC&&rd(c,0xCFFC)==0x6C&&rd(c,0xCFFD)==0x41,"A12 variant raw dispatcher actual return stack stop before indirect jump",index);
  require(cpu->a==offset&&cpu->f.packed==(offset?0:0x80)&&cpu->bc==0xBEEF&&cpu->de==target&&cpu->hl==target&&rd(c,0xC5A8)==variant,"A12 raw variant byte-wrapped target and registers no range guard",index);
 }
 const unsigned selectors[]={0x61,0x63,0x65,0x66},returns[]={0x4182,0x41AF,0x41DF,0x420F};
 for(unsigned variant=0;variant<4;variant++)for(unsigned prior=0;prior<256;prior++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5A3,1);wr(c,0xC5A8,variant);wr(c,0xC21B,0x33);wr(c,0xC21C,prior^255);wr(c,0xC21D,prior);wr(c,0xC21E,0x5A);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->af=prior<<8|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x413A;
  unsigned steps=0,index=variant*4096+prior*16+flags;while(cpu->pc!=0x5051&&steps++<200)c->step(c);
  require(cpu->pc==0x5051&&cpu->sp==0xCFF8,"A12 both original dispatchers reach common5051 callee prefix",index);
  require((rd(c,0xCFF8)|(rd(c,0xCFF9)<<8))==returns[variant]&&(rd(c,0xCFFA)|(rd(c,0xCFFB)<<8))==0x416C&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==0x414F&&(rd(c,0xCFFE)|(rd(c,0xCFFF)<<8))==0xC100,
   "A12 variant callee prefix exact nested return chain",index);
  require(cpu->a==0&&cpu->f.packed==(variant?0:0x80)&&cpu->bc==0xBEEF&&rd(c,0xC21C)==selectors[variant]&&rd(c,0xC21D)==0&&rd(c,0xC21B)==0x33&&rd(c,0xC21E)==0x5A&&rd(c,0xC5A3)==1&&rd(c,0xC5A8)==variant,
   "A12 four variant original text selector prefix guards and flags",index);
 }
 }
 { /* Forced variant tails after preceding callees; original counter arithmetic. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);struct GB *g=c->board;
 const unsigned entries[]={0x4182,0x41B2,0x41E2,0x420F},stops[]={0x418F,0x41BF,0x41EF,0x4213};
 for(unsigned variant=0;variant<4;variant++)for(unsigned counter=0;counter<256;counter++)for(unsigned option=0;option<256;option++){
  unsigned initialFlags=(option&15)<<4,amount=variant==3||!option?1:4,value=(counter+amount)&255,index=variant*65536+counter*256+option;
  unsigned expectedFlags=variant==3?((initialFlags&0x10)|(value?0:0x80)|((value&15)?0:0x20)):!option?0xA0:((value?0:0x80)|((value&15)?0:0x20));
  wr(c,0xC5E4,0x33);wr(c,0xC5E5,counter);wr(c,0xC5E6,0x5A);wr(c,0xC73A,option);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->af=0x5A00|initialFlags;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=entries[variant];
  unsigned steps=0;while(cpu->pc!=stops[variant]&&steps++<100)c->step(c);
  require(cpu->pc==stops[variant]&&cpu->sp==0xCFFE,"A12 variant counter tail stops before original next call",index);
  require(rd(c,0xC5E5)==value&&rd(c,0xC5E4)==0x33&&rd(c,0xC5E6)==0x5A&&rd(c,0xC73A)==option&&cpu->a==(variant==3?0x5A:option)&&cpu->f.packed==expectedFlags&&cpu->bc==0xBEEF&&cpu->de==0x5678&&cpu->hl==0xC5E5,
   "A12 counter all byte pairs increment1 or4 wrap independent INC AND flags guards",index);
 }
 }
 { /* Complete idle exit gate, every fade/audio byte pair and incoming flags. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned fade=0;fade<256;fade++)for(unsigned busy=0;busy<256;busy++)for(unsigned flags=0;flags<16;flags++){
  unsigned state=(fade*73+busy)&255,value=fade|busy,index=fade*4096+busy*16+flags;
  wr(c,0xC220,fade);wr(c,0xCF86,busy);wr(c,0xC5A2,0x33);wr(c,0xC5A3,state);wr(c,0xC5A4,0x5A);
  cpu->af=0xA500|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;call(c,0x421D);
  require(cpu->a==value&&cpu->f.packed==(value?0:0x80)&&cpu->bc==(0xBE00|fade)&&cpu->de==0x5678&&cpu->hl==0x9ABC&&rd(c,0xC5A3)==(value?state:0)&&rd(c,0xC5A2)==0x33&&rd(c,0xC5A4)==0x5A&&rd(c,0xC220)==fade&&rd(c,0xCF86)==busy,
   "A12 full idle gate OR domains clears state only after fade and audio zero",index);
 }
 }
 { /* Original callback no-op and window positioning, all incoming AF values. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned a=0;a<256;a++)for(unsigned flags=0;flags<16;flags++){
  cpu->af=a<<8|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;wr(c,0xFF8A,0x33);wr(c,0xC5A9,0x5A);call(c,0x422F);
  require(cpu->af==(a<<8|flags<<4)&&cpu->bc==0xBEEF&&cpu->de==0x5678&&cpu->hl==0x9ABC&&rd(c,0xFF8A)==0x33&&rd(c,0xC5A9)==0x5A,"A12 interrupt callback no-op complete AF preserves registers guards",a*16+flags);
  wr(c,0xFF4B,0x55);wr(c,0xFF4A,0x44);cpu->af=a<<8|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;call(c,0x4230);
  require(cpu->a==0&&cpu->f.packed==flags<<4&&cpu->bc==0xBEEF&&cpu->de==0x5678&&cpu->hl==0x9ABC&&rd(c,0xFF4B)==0xA7&&rd(c,0xFF4A)==0&&rd(c,0xFF8A)==0x33&&rd(c,0xC5A9)==0x5A,"A12 full window callback sets A7 zero preserves flags and other registers",a*16+flags);
 }
 }
 { /* Original conditional DMA and palette callback, LCDoff synthetic memory. */
 wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);call(c,0x09EB);
 bool exact=true;for(unsigned i=0;i<10;i++)exact&=rd(c,0xFF80+i)==rd(c,0x09F9+i);
 require(exact,"A12 callback actual original HRAM DMA template installed",0);
 for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
 const unsigned dirties[]={0,1,255};unsigned index=0;
 for(unsigned family=0;family<2;family++)for(unsigned input=0;input<256;input++)for(unsigned n=0;n<(family?2:3);n++)for(unsigned plane=0;plane<2;plane++){
  unsigned dma=family?n:input,dirty=family?input:dirties[n];
  for(unsigned i=0;i<160;i++){wr(c,0xC000+i,(i*37+dma*19+dirty)&255);wr(c,0xFE00+i,0x6D);}wr(c,0xC0A0,0x33);
  for(unsigned i=0;i<128;i++)wr(c,0xC222+i,(i*29+dirty*11+dma*17)&255);wr(c,0xC220,0x5A);wr(c,0xC2A2,0x3C);
  for(unsigned p=0;p<2;p++)for(unsigned i=0;i<64;i++){wr(c,p?0xFF6A:0xFF68,i);wr(c,p?0xFF6B:0xFF69,0x19);}
  wr(c,0xFF4F,plane);wr(c,0xC5A9,dma);wr(c,0xC221,dirty);wr(c,0xFF8A,0x33);wr(c,0xFF43,0xA5);wr(c,0xFF42,0x5A);wr(c,0xFF4B,0x44);wr(c,0xFF4A,0x55);
  cpu->af=0xA500|((input&15)<<4);cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;call(c,0x4239);
  require(cpu->af==0x0080&&cpu->bc==0xBEEF&&cpu->de==0x5678&&cpu->hl==0x9ABC&&rd(c,0xC5A9)==dma&&rd(c,0xC221)==0&&rd(c,0xC220)==0x5A&&rd(c,0xC2A2)==0x3C&&rd(c,0xC0A0)==0x33&&rd(c,0xFF8A)==0x33&&rd(c,0xFF43)==0&&rd(c,0xFF42)==0&&rd(c,0xFF4B)==7&&rd(c,0xFF4A)==0&&(rd(c,0xFF4F)&1)==plane,
   "A12 full conditional callback AF registers scroll window independent flags guards",index);
  exact=true;for(unsigned i=0;i<160;i++)exact&=rd(c,0xFE00+i)==(dma?((i*37+dma*19+dirty)&255):0x6D)&&rd(c,0xC000+i)==((i*37+dma*19+dirty)&255);
  require(exact,"A12 DMA only when C5A9 nonzero exact160 OAM bytes and source unchanged",index);
  exact=true;for(unsigned p=0;p<2;p++)for(unsigned i=0;i<64;i++){wr(c,p?0xFF6A:0xFF68,i);unsigned expected=dirty?(((p*64+i)*29+dirty*11+dma*17)&255):0x19;exact&=rd(c,p?0xFF6B:0xFF69)==expected;}
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)exact&=rd(c,0x8000+i)==0xA5;}wr(c,0xFF4F,plane);
  require(exact,"A12 palettes only when dirty independent of DMA all palette bytes both whole VRAM planes",index++);
 }
 }
 { /* Local byte multiply: all HL inputs plus selected full AF products. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned value=0;value<65536;value++){
  unsigned a=value&255;cpu->a=a;cpu->f.packed=((value>>8)&15)<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=value;call(c,0x5CFF);
  require(cpu->hl==(value>>8)*(value&255)&&cpu->a==a&&cpu->f.packed==0xC0&&cpu->bc==0xBEEF&&cpu->de==0x5678,"A12 byte multiply full HL domain exact product preserves A BC DE flags",value);
 }
 const unsigned inputs[]={0,1,0x0100,0x0101,0x7F80,0x80FF,0xFF80,0xFFFF};
 for(unsigned n=0;n<8;n++)for(unsigned a=0;a<256;a++)for(unsigned flags=0;flags<16;flags++){
  cpu->a=a;cpu->f.packed=flags<<4;cpu->bc=0x1234;cpu->de=0x5678;cpu->hl=inputs[n];call(c,0x5CFF);
  require(cpu->hl==(inputs[n]>>8)*(inputs[n]&255)&&cpu->a==a&&cpu->f.packed==0xC0&&cpu->bc==0x1234&&cpu->de==0x5678,"A12 multiply selected HL full incoming AF domain",n*4096+a*16+flags);
 }
 }
 { /* Complete early returns and original tick prefixes before tile copy. */
 unsigned index=0;for(unsigned threshold=0;threshold<256;threshold++)for(unsigned counter=0;counter<256;counter++)for(unsigned flags=0;flags<16;flags++)probeA12FrameGate(c,threshold,counter,3,1,1,flags<<4,index++);
 const unsigned loops[]={0,1,255};for(unsigned frames=0;frames<256;frames++)for(unsigned frame=0;frame<256;frame++)for(unsigned n=0;n<3;n++)probeA12FrameGate(c,1,1,frames,frame,loops[n],((frames^frame)&15)<<4,index++);
 for(unsigned loop=0;loop<256;loop++)for(unsigned flags=0;flags<16;flags++)probeA12FrameGate(c,1,1,17,16,loop,flags<<4,index++);
 }
 { /* Full copies with original resources and WRAM records; zero dimensions excluded. */
 const unsigned shapes[][2]={{1,1},{2,3},{3,2},{16,16},{17,17},{31,9}};unsigned index=0;
 for(unsigned shape=0;shape<6;shape++)for(unsigned kind=0;kind<3;kind++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++)for(unsigned entry=0;entry<3;entry++)probeA12FrameCopy(c,shapes[shape][0],shapes[shape][1],kind,plane,lcd,entry,index++);
 for(unsigned shape=0;shape<6;shape++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++)probeA12FrameCopy(c,shapes[shape][0],shapes[shape][1],2,plane,lcd,3,index++);
 }
 { /* State seed/step full state domain; eight selected states full AF domain. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);const unsigned states[]={0,1,0x0100,0x7FFF,0x8000,0xFF00,0xFFFE,0xFFFF};unsigned index=0;
 for(unsigned seed=0;seed<2;seed++){
  for(unsigned state=0;state<65536;state++)probeA12Random(c,state,state&255,((state>>8)&15)<<4,seed,index++);
  for(unsigned n=0;n<8;n++)for(unsigned a=0;a<256;a++)for(unsigned flags=0;flags<16;flags++)probeA12Random(c,states[n],a,flags<<4,seed,index++);
 }
 }
 { /* Full guarded trigger seed/flags prefixes, never executing unknown mapping. */
 wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);wr(c,0x37FF,0x63);wr(c,0x3800,0);wr(c,0xC21C,0x63);wr(c,0xC21D,0);
 for(unsigned seed=0;seed<65536;seed++)for(unsigned flags=0;flags<16;flags++)probeA12TriggerPrefix(c,seed,flags<<4,seed*16+flags);
 }
 { /* Every guard byte and flags, fixing the other guards and non-trigger seed. */
 unsigned none=0,state,previous;while(a12TriggerChoice(none,&state,&previous))none++;
 for(unsigned guard=0;guard<3;guard++)for(unsigned value=0;value<256;value++)for(unsigned flags=0;flags<16;flags++){
  unsigned stage=guard==0?value:6,phase=guard==1?value:1,threshold=guard==2?value:0,expectedA,expectedF,expectedState=none,expectedDE=0x5678,expectedHL=0x9ABC;
  if(stage!=6){expectedA=stage;expectedF=0x40|(stage==6?0x80:0)|((stage&15)<6?0x20:0)|(stage<6?0x10:0);}
  else if(phase!=1){expectedA=phase;expectedF=0x40|((phase&15)<1?0x20:0)|(phase<1?0x10:0);}
  else if(threshold){expectedA=threshold;expectedF=0x40;}
  else{a12TriggerChoice(none,&expectedState,&previous);expectedA=(expectedState>>8)&15;expectedF=0x20;expectedDE=(expectedState&255)<<8|expectedState>>8;expectedHL=(17*previous)&65535;}
  wr(c,0xC5A4,stage);wr(c,0xC5CF,phase);wr(c,0xC5E4,threshold);wr(c,0xC5E5,0xA5);wr(c,0xC5E7,0x5A);wr(c,0xC5D2,none&255);wr(c,0xC5D3,none>>8);
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;call(c,0x4C11);
  require(cpu->a==expectedA&&cpu->f.packed==expectedF&&cpu->bc==0xBEEF&&cpu->de==expectedDE&&cpu->hl==expectedHL&&(rd(c,0xC5D2)|(rd(c,0xC5D3)<<8))==expectedState&&rd(c,0xC5A4)==stage&&rd(c,0xC5CF)==phase&&rd(c,0xC5E4)==threshold&&rd(c,0xC5E5)==0xA5&&rd(c,0xC5E7)==0x5A,"A12 all guard bytes early return CP flags RNG untouched or two real steps",guard*4096+value*16+flags);
 }
 }
 { /* Explicit current B mapping control at header-read boundary. */
 unsigned selected[3][2]={{0}},counts[3]={0},state,previous;for(unsigned seed=0;seed<65536;seed++){unsigned choice=a12TriggerChoice(seed,&state,&previous);if(counts[choice]<2)selected[choice][counts[choice]++]=seed;}
 const unsigned headers[2][7]={{7,10,2,1,5,8,0},{5,11,3,1,4,8,0}};
 for(unsigned choice=1;choice<=2;choice++)for(unsigned bank=0;bank<2;bank++){
  wr(c,0x37FF,bank?0x63:5);wr(c,0x3800,0);wr(c,0xC21C,0x63);wr(c,0xC21D,0);probeA12TriggerPrefix(c,selected[choice][0],0xF0,choice*2+bank);
  bool matches=true;for(unsigned i=0;i<7;i++)matches&=rd(c,cpu->hl+i)==headers[choice-1][i];
  require(matches==(bank!=0)&&rd(c,0xC21C)==0x63,"A12 header positive B63 and negative B05 request field alone does not map header",choice*2+bank);
 }
 { /* Full resource consumer and all subsequent frames under prepared B63. */
 struct GB *g=c->board;unsigned index=0;
 for(unsigned choice=0;choice<3;choice++)for(unsigned n=0;n<2;n++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++){
  unsigned seed=selected[choice][n],rng;unsigned actual=a12TriggerChoice(seed,&rng,&previous);require(actual==choice,"A12 selected seed positive controls cover all three paths",index);
  unsigned header=choice==1?0x6A96:0x6AB1,width=choice?headers[choice-1][2]:0,height=choice?headers[choice-1][3]:0,frames=choice?headers[choice-1][4]:0,area=width*height,payload[32];
  wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);wr(c,0xFFAB,0x12);wr(c,0xFFAC,0);wr(c,0xC113,0x12);wr(c,0xC114,0);
  wr(c,0x37FF,0x63);wr(c,0x3800,0);wr(c,0xFFAD,0x63);wr(c,0xFFAE,0);wr(c,0xC115,0x63);wr(c,0xC116,0);wr(c,0xC21C,0x63);wr(c,0xC21D,0);
  for(unsigned i=0;i<frames*2*area;i++)payload[i]=rd(c,header+7+i);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}wr(c,0xFF4F,plane);
  wr(c,0xC5A4,6);wr(c,0xC5CF,1);wr(c,0xC5E4,0);wr(c,0xC5E5,0xA5);wr(c,0xC5E7,0x5A);wr(c,0xC5D2,seed&255);wr(c,0xC5D3,seed>>8);wr(c,0xC5D1,0x33);wr(c,0xC5D4,0x5A);wr(c,0xC5FD,0x3C);
  cpu->af=0x5AF0;cpu->bc=0xBEEF;cpu->de=0x5678;cpu->hl=0x9ABC;wr(c,0xFF40,lcd?0x91:0);call(c,0x4C11);wr(c,0xFF40,0);
  bool exact=(rd(c,0xC5D2)|(rd(c,0xC5D3)<<8))==rng&&rd(c,0xC5D1)==0x33&&rd(c,0xC5D4)==0x5A&&rd(c,0xC5FD)==0x3C&&rd(c,0xC113)==0x12&&rd(c,0xC114)==0&&rd(c,0xC115)==0x63&&rd(c,0xC116)==0&&(rd(c,0xFF4F)&1)==plane;
  if(choice){unsigned end=header+7+2*area;exact&=cpu->af==0x0080&&cpu->bc==(width<<8|height)&&cpu->de==header+7&&cpu->hl==end&&(rd(c,0xC5F7)<<8|rd(c,0xC5F8))==end&&(rd(c,0xC5FB)<<8|rd(c,0xC5FC))==header+7&&rd(c,0xC5E4)==8&&rd(c,0xC5E5)==0&&rd(c,0xC5E6)==frames&&rd(c,0xC5E7)==0&&rd(c,0xC5E8)==0&&g->memory.ime;}
  else exact&=cpu->a==((rng>>8)&15)&&cpu->f.packed==0x20&&cpu->bc==0xBEEF&&cpu->de==((rng&255)<<8|rng>>8)&&cpu->hl==((17*previous)&65535)&&rd(c,0xC5E4)==0&&rd(c,0xC5E5)==0xA5&&rd(c,0xC5E7)==0x5A;
  require(exact,"A12 full guarded consumer selects actual B63 resource or returns no trigger registers state",index);
  for(unsigned frame=0;frame<(choice?frames:1);frame++){
   if(frame){wr(c,0xFF4F,plane);wr(c,0xC5E5,8);wr(c,0xFF40,lcd?0x91:0);call(c,0x5051);wr(c,0xFF40,0);}
   exact=true;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){unsigned x=i%32,y=(i/32)&31;bool tile=choice&&i>=0x1800&&i<0x1C00&&x>=headers[choice-1][0]&&x<headers[choice-1][0]+width&&y>=headers[choice-1][1]&&y<headers[choice-1][1]+height;unsigned expected=tile?payload[frame*2*area+bank*area+(y-headers[choice-1][1])*width+x-headers[choice-1][0]]:0xA5;exact&=rd(c,0x8000+i)==expected;}}
   require(exact,"A12 full B63 frame sequence exact both complete VRAM planes no font translation",index*8+frame);
  }
  if(choice){wr(c,0xFF4F,plane);wr(c,0xC5E5,8);call(c,0x5051);unsigned end=header+7+frames*2*area;
   require(cpu->af==0x0080&&rd(c,0xC5E4)==0&&rd(c,0xC5E5)==0&&rd(c,0xC5E7)==0&&(rd(c,0xC5F7)<<8|rd(c,0xC5F8))==end&&(rd(c,0xC5FB)<<8|rd(c,0xC5FC))==header+7,"A12 original terminal tick clears threshold without copying beyond prepared resource",index);
  }
  index++;
 }
 }
 }
 { /* All seeds: exact twenty RNG steps and all forty row bytes. */
 for(unsigned seed=0;seed<65536;seed++)probeA12TileCycle(c,seed,seed>>8,seed&1,false,seed);
 /* For every column, force a candidate high byte of zero, then all tile bytes
    on both planes. Complete VRAM comparison for recognized/edge tile values. */
 unsigned chosen[20];for(unsigned col=0;col<20;col++){chosen[col]=65536;for(unsigned seed=0;seed<65536;seed++){
  unsigned state=seed;for(unsigned i=0;i<=col;i++)state=a12NextState(state);
  if(!(state>>8)){chosen[col]=seed;break;}
 }require(chosen[col]<65536,"A12 synthetic trigger seed exists at each column",col);}
 for(unsigned col=0;col<20;col++)for(unsigned tile=0;tile<256;tile++)for(unsigned plane=0;plane<2;plane++)
  probeA12TileCycle(c,chosen[col],(tile-col)&255,plane,tile==0||tile==0xA4||tile==0xA5||tile==0xA6||tile==0xA7||tile==0xA8||tile==255,65536+col*512+tile*2+plane);
 }
 { /* Raw indices: stop at the real indexed-record thunk, do not consume invalid records. */
 struct GB *g=c->board;wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned entry=0;entry<2;entry++)for(unsigned index=0;index<256;index++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5A5,index);wr(c,0xC5C4,0xA5);wr(c,0xC1C2,0x5A);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->af=index<<8|flags<<4;cpu->bc=0xBEEF;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=entry?0x4CD8:0x4C88;
  unsigned steps=0;while(cpu->pc!=0x1E3&&steps++<100)c->step(c);
  require(cpu->pc==0x1E3&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==(entry?0x4CE4:0x4C91),"A12 text raw index actual thunk and original return prefix",entry*4096+index*16+flags);
  require(cpu->af==(index<<8|flags<<4)&&cpu->de==0x5314&&cpu->bc==0xBEEF&&cpu->hl==0x5678&&rd(c,0xC5C4)==index&&rd(c,0xC5A5)==index&&rd(c,0xC1C2)==0x5A,"A12 text raw index flags fields preserved no validity clamp",entry*4096+index*16+flags);
 }
 /* Both LCD control wrappers, every incoming LCDC and flags, actual callee boundary. */
 for(unsigned hide=0;hide<2;hide++)for(unsigned lcd=0;lcd<256;lcd++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xFF40,0);wr(c,0xFF40,lcd);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=hide?0x4CB8:0x4CA6;
  unsigned target=hide?0x294:0x24F,steps=0;while(cpu->pc!=target&&steps++<10000)c->step(c);
  require(cpu->pc==target&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==(hide?0x4CD7:0x4CB7),"A12 visibility actual copy or audio thunk prefix",hide*4096+lcd*16+flags);
  require(rd(c,0xFF40)==(hide?lcd&0x9F:lcd|0x60)&&cpu->af==(hide?0x8700:0x9A00)&&cpu->bc==(hide?0:0xBEEF)&&cpu->de==(hide?0xD000:0x1234)&&cpu->hl==(hide?0x1408:0x5678),"A12 visibility all LCDC flags exact mask and callee arguments",hide*4096+lcd*16+flags);
 }
 /* Complete preparation: four real records, both planes/LCD states and four attrs. */
 const unsigned widths[]={18,14,11,5},heights[]={2,3,2,3},attrs[]={0,1,0x23,255};
 for(unsigned record=0;record<4;record++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++)for(unsigned attr=0;attr<4;attr++){
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF4F,plane);wr(c,0xFF70,2);wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1A3,attrs[attr]);wr(c,0xC1B8,0x5A);wr(c,0xC1AB,0x3C);wr(c,0xC1C2,0xA5);wr(c,0xC5C3,0x37);wr(c,0xC5A6,0x39);wr(c,0xC1C1,0x41);
  cpu->af=record<<8|attr<<4;cpu->bc=0xBEFF;cpu->de=0x1234;cpu->hl=0x5678;if(lcd)wr(c,0xFF40,0x91);callWithLimit(c,0x4C88,2000000);
  unsigned rows=2*heights[record]+2,width=widths[record];
  bool exact=cpu->a==0&&cpu->f.packed==(plane?0x20:0xA0)&&cpu->bc==0&&cpu->de==0x9874&&cpu->hl==0x9800+(rows-1)*32+width+1&&rd(c,0xC5C4)==record&&rd(c,0xC5A5)==record&&rd(c,0xC1C2)==0&&rd(c,0xC1A4)==1&&rd(c,0xC1A7)==2&&rd(c,0xC1A8)==width&&rd(c,0xC1A9)==heights[record]&&rd(c,0xC1AA)==1&&rd(c,0xC1B8)==0x5A&&rd(c,0xC1AB)==0x3C&&rd(c,0xC5C3)==0x37&&rd(c,0xC5A6)==0x39&&rd(c,0xC1C1)==0x41&&(rd(c,0xFF4F)&1)==plane;
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){
   unsigned row=i>=0x1800?(i-0x1800)/32:256,col=i%32,expected=0xA5;
   if(row<rows&&col<width+2)expected=bank?attrs[attr]:0x6C+(row==0?0:row==rows-1?6:3)+(col==0?0:col==width+1?2:1);
   exact&=rd(c,0x8000+i)==expected;
  }}require(exact,"A12 complete indexed preparation exact both VRAM planes records registers fields guards",record*16+plane*8+lcd*4+attr);
 }
 /* Complete copies: fixed hide rectangle and four record-sized current regions. */
 for(unsigned family=0;family<5;family++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++){
  unsigned width=family?widths[family-1]+2:20,height=family?2*heights[family-1]+2:8,area=width*height,base=family?0x9800:0x9C00;
  wr(c,0xFF40,0);wr(c,0x27FF,0x12);wr(c,0x2800,0);wr(c,0xFFAB,0x12);wr(c,0xFFAC,0);wr(c,0xC113,0x12);wr(c,0xC114,0);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
  wr(c,0xFF70,7);for(unsigned i=0;i<2*area;i++)wr(c,0xD000+i,(i*13+family)&255);wr(c,0xCFFF,0x3C);wr(c,0xD000+2*area,0x5A);wr(c,0xFF70,2);wr(c,0xFF4F,plane);
  wr(c,0xC5A5,family?family-1:3);wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1B8,0x37);wr(c,0xC1C2,0x39);cpu->bc=0xBEFF;cpu->af=0x5AF0;
  wr(c,0xFF40,lcd?0xF1:0x60);callWithLimit(c,family?0x4CD8:0x4CB8,2000000);
  bool exact=(rd(c,0xFF70)&7)==2&&(rd(c,0xFF4F)&1)==0&&rd(c,0xFFAB)==0x12&&rd(c,0xFFAC)==0&&rd(c,0xC113)==0x12&&rd(c,0xC114)==0&&rd(c,0xC1B8)==0x37&&rd(c,0xC1C2)==0x39&&rd(c,0xC63A)==(family?7:0x87)&&rd(c,0xFF40)==(family?(lcd?0xF1:0x60):(lcd?0x91:0));
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){
   unsigned address=0x8000+i,row=address>=base?(address-base)/32:256,col=i%32,expected=0xA5;
   if(row<height&&col<width)expected=((bank*area+row*width+col)*13+family)&255;
   exact&=rd(c,address)==expected;
  }}wr(c,0xFF70,7);for(unsigned i=0;i<2*area;i++)exact&=rd(c,0xD000+i)==((i*13+family)&255);exact&=rd(c,0xD000+2*area)==0x5A;wr(c,0xFF70,2);
  require(exact,"A12 complete real resident banked copy exact VRAM source guards mapper and WRAM restoration",family*4+plane*2+lcd);
 }
 wr(c,0xFF40,0);
 }
 { /* Dispatch, resets and tick: actual boundaries, never fabricated callees. */
 struct GB *g=c->board;const unsigned entries[]={0x4D44,0x4D48,0x4D4C,0x4D50},tables[]={0x6BBD,0x6AD0,0x6AE5,0x6A3D};
 wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned index=0;index<256;index++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5A8,index);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4D26;
  unsigned offset=(index*2)&255,pointer=0x4D3C+offset,target=rd(c,pointer)|(rd(c,pointer+1)<<8),steps=0;
  while(cpu->pc!=0x4D3A&&steps++<100)c->step(c);
  require(cpu->pc==0x4D3A&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==0x4D3B,"A12 resource raw dispatcher original synthetic return prefix",index*16+flags);
  require(cpu->hl==target&&cpu->de==target&&cpu->bc==0xBEEF&&cpu->a==offset&&cpu->f.packed==(offset?0:0x80)&&rd(c,0xC5A8)==index,"A12 resource all raw indices wrapped selector actual table word no validity assertion",index*16+flags);
 }
 for(unsigned family=0;family<3;family++)for(unsigned variant=0;variant<4;variant++)for(unsigned flags=0;flags<16;flags++){
  unsigned raw=variant+(family==2?128:0);wr(c,0xC5A8,raw);cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,family?0x4D26:entries[variant]);
  require(cpu->hl==tables[variant]&&cpu->bc==0xBEEF&&cpu->de==(family?entries[variant]:0x1234)&&cpu->af==(family?((variant*2)<<8|(variant?0:0x80)):(0x5A00|flags<<4)),"A12 four complete table setters and valid dispatcher aliases preserve contract",family*64+variant*16+flags);
 }
 for(unsigned extended=0;extended<2;extended++)for(unsigned rawCase=0;rawCase<8;rawCase++)for(unsigned phase=0;phase<256;phase++){
  unsigned variant=rawCase&3,raw=variant+(rawCase>=4?128:0);wr(c,0xC5A8,raw);wr(c,0xC5CF,phase);wr(c,0xC5CC,0xA5);wr(c,0xC5CE,0x5A);wr(c,0xC5CB,0x37);wr(c,0xC5CD,0x39);
  wr(c,0xC5E4,0x11);wr(c,0xC5E5,0x22);wr(c,0xC5E6,0x33);wr(c,0xC5E7,0x44);wr(c,0xC5E3,0x55);wr(c,0xC5E8,0x66);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|((phase&15)<<4);cpu->bc=0xBEEF;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=extended?0x4D0B:0x4CFD;
  unsigned steps=0;while(cpu->pc!=0x4D82&&steps++<200)c->step(c);
  require(cpu->pc==0x4D82&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==(extended?0x4D25:0x4D0A)&&cpu->hl==tables[variant]&&cpu->de==entries[variant]&&cpu->bc==0xBEEF&&cpu->af==((variant*2)<<8|(variant?0:0x80)),"A12 both resets original reader prefix stack selected table registers",extended*2048+rawCase*256+phase);
  require(rd(c,0xC5CC)==0&&rd(c,0xC5CE)==0&&rd(c,0xC5CF)==phase&&rd(c,0xC5CB)==0x37&&rd(c,0xC5CD)==0x39&&rd(c,0xC5E4)==(extended?0:0x11)&&rd(c,0xC5E5)==(extended?0:0x22)&&rd(c,0xC5E6)==(extended?0:0x33)&&rd(c,0xC5E7)==(extended?0:0x44)&&rd(c,0xC5E3)==0x55&&rd(c,0xC5E8)==0x66,"A12 reset exact counter fields guard bytes and unchanged phase",extended*2048+rawCase*256+phase);
 }
 for(unsigned family=0;family<2;family++){
 unsigned n=family?65536:1048576;
 for(unsigned sample=0;sample<n;sample++){
  unsigned threshold=family?0:sample>>12,counter=family?0:(sample>>4)&255,flags=family?(sample&15)<<4:(sample&15)<<4,count=family?sample>>8:10,frame=family?sample&255:6,raw=family?3:0;
  unsigned next=(frame+1)&255;bool below=counter<threshold,reset=!below&&next==count;
  wr(c,0xC5A8,raw);wr(c,0xC5CB,threshold);wr(c,0xC5CC,counter);wr(c,0xC5CD,count);wr(c,0xC5CE,frame);wr(c,0xC5CF,0x37);wr(c,0xC5D1,0xA5);wr(c,0xC5CA,0x3C);wr(c,0xC5D2,0x5A);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4D54;
  unsigned target=below?0x4EEA:0x4D82,steps=0;while(cpu->pc!=target&&steps++<300)c->step(c);
  unsigned expectedF=below?0x40|(((counter-threshold)&255)==0?0x80:0)|((counter&15)<(threshold&15)?0x20:0)|0x10:(raw?0:0x80);
  require(cpu->pc==target&&cpu->sp==(below?0xCFFE:reset?0xCFFA:0xCFFC)&&
   (below||((rd(c,cpu->sp)|(rd(c,cpu->sp+1)<<8))==(reset?0x4D0A:0x4D81)&&(!reset||(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==0x4D77)))&&
   cpu->a==(below?(counter-threshold)&255:raw*2)&&cpu->f.packed==expectedF&&cpu->bc==((below?threshold:count)<<8|0x37)&&cpu->de==(below?0x1234:entries[raw])&&cpu->hl==(below?0x5678:tables[raw]),"A12 tick exhaustive gate or frame transition actual boundary stack registers flags",family*1048576+sample);
  require(rd(c,0xC5CC)==(below?counter:0)&&rd(c,0xC5CE)==(below?frame:reset?0:next)&&rd(c,0xC5CF)==(reset?0xA5:0x37)&&rd(c,0xC5CD)==count&&rd(c,0xC5D1)==0xA5&&rd(c,0xC5CA)==0x3C&&rd(c,0xC5D2)==0x5A,"A12 tick subtraction threshold wrap exact reset phase and WRAM guards",family*1048576+sample);
 }
 }
 }
 { /* Wrapped coordinate offsets and independent unsigned distances. */
 wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned value=0;value<256;value++)for(unsigned flags=0;flags<16;flags++){
  unsigned in[]={value,(value*37)&255,(value*73)&255,(value*109)&255};
  wr(c,0xC5D7,in[0]);wr(c,0xC5D8,in[1]);wr(c,0xC5D9,in[2]);wr(c,0xC5DA,in[3]);wr(c,0xC5D6,0x37);wr(c,0xC5DB,0x39);
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x4E7A);
  unsigned a=(in[3]-0xD0)&255,f=0x40|(a?0:0x80)|(in[3]<0xD0?0x10:0);
  require(cpu->a==a&&cpu->f.packed==f&&cpu->bc==0xD037&&cpu->de==0x1234&&cpu->hl==0x5678&&rd(c,0xC5D7)==((in[0]-0xC9)&255)&&rd(c,0xC5D8)==((in[1]-0xD0)&255)&&rd(c,0xC5D9)==((in[2]-0xC9)&255)&&rd(c,0xC5DA)==a&&rd(c,0xC5D6)==0x37&&rd(c,0xC5DB)==0x39,"A12 offsets all byte inputs flags wrap exact fields and guards",value*16+flags);
 }
 for(unsigned x=0;x<256;x++)for(unsigned y=0;y<256;y++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5D7,x);wr(c,0xC5D9,y);wr(c,0xC5D8,y);wr(c,0xC5DA,x);wr(c,0xC5DC,0x37);wr(c,0xC5DF,0x39);
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x4EA3);
  unsigned hi=x>y?x:y,lo=x<y?x:y,d=hi-lo,f=0x40|(d?0:0x80)|((hi&15)<(lo&15)?0x20:0);
  require(cpu->a==d&&cpu->f.packed==f&&cpu->bc==(lo<<8|0x37)&&cpu->de==0x1234&&cpu->hl==0x5678&&rd(c,0xC5DD)==d&&rd(c,0xC5DE)==d&&rd(c,0xC5D7)==x&&rd(c,0xC5D9)==y&&rd(c,0xC5D8)==y&&rd(c,0xC5DA)==x&&rd(c,0xC5DC)==0x37&&rd(c,0xC5DF)==0x39,"A12 distances all unsigned byte pairs flags both comparison branches",x*4096+y*16+flags);
 }
 }
 { /* Requested B mapping checked independently before the actual pointer read. */
 struct GB *g=c->board;
 const unsigned banks[]={0,5,0x61,0x63,0x65,0x66,127},signatures[7][4]={{195,245,5,0},{118,0,240,138},{136,135,167,151},{128,129,130,131},{191,191,191,187},{245,245,7,0},{0,0,0,0}};

 wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned bank=0;bank<7;bank++)for(unsigned phase=0;phase<256;phase++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0x37FF,5);wr(c,0x3800,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);wr(c,0xC115,5);wr(c,0xC116,0);wr(c,0xC21C,banks[bank]);wr(c,0xC21D,0);wr(c,0xC5CF,phase);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBE37;cpu->hl=0xD000;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4D82;
  unsigned steps=0;while(cpu->pc!=0x4DA2&&steps++<100)c->step(c);
  require(cpu->pc==0x4DA2&&cpu->hl==0xD000+((phase*2)&255)&&cpu->de==((phase*2)&255)&&cpu->bc==0xBE37&&cpu->sp==0xCFFE&&rd(c,0xFF9D)==5&&rd(c,0xFF9E)==0&&rd(c,0xFFAD)==banks[bank]&&rd(c,0xFFAE)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0,"A12 reader original requested mapping writes HRAM backup raw phase pointer boundary",bank*4096+phase*16+flags);
  bool exact=true;for(unsigned i=0;i<4;i++)exact&=rd(c,0x6000+i)==signatures[bank][i];require(exact,"A12 reader seven independently measured ROM window signatures actual mapping",bank*4096+phase*16+flags);
 }
 /* Prepared WRAM table/records, not claimed natural resource geometry. */
 for(unsigned i=0;i<128;i++){wr(c,0xD000+2*i,0);wr(c,0xD001+2*i,0xD2);}wr(c,0xD200,17);
 for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}
 for(unsigned phase=0;phase<256;phase++)for(unsigned frame=0;frame<256;frame++){
  unsigned start=0xD201+4*frame,pattern=frame%4,skip=pattern==3?8:pattern?4:0,target=start+4+skip;
  unsigned rawX=(frame*37)&255,rawY=(phase*73)&255,endX=(phase*17)&255,endY=(frame*19)&255,nextPhase=phase%254,threshold=(phase+frame)&255;
  const unsigned current[]={frame%254,rawX,rawY,threshold},next[]={nextPhase,endX,endY,0x53};
  for(unsigned i=0;i<4;i++){wr(c,start+i,current[i]);wr(c,target+i,next[i]);}
  if(pattern==1||pattern==3){wr(c,start+4,255);for(unsigned i=1;i<4;i++)wr(c,start+4+i,0xA5);}
  if(pattern==2||pattern==3){unsigned m=start+4+(pattern==3?4:0);wr(c,m,254);for(unsigned i=1;i<4;i++)wr(c,m+i,0x5A);}
  wr(c,0x37FF,5);wr(c,0x3800,0);wr(c,0xFFAD,5);wr(c,0xFFAE,0);wr(c,0xC115,5);wr(c,0xC116,0);wr(c,0xC21C,0x63);wr(c,0xC21D,0);wr(c,0xC5CF,phase);wr(c,0xC5CE,frame);wr(c,0xC5CC,0x37);wr(c,0xC5D6,0x39);wr(c,0xC5DB,0x3C);wr(c,0xC5DF,0x5A);
  cpu->af=0x5A00|((phase&15)<<4);cpu->bc=0xBE37;cpu->hl=0xD000;call(c,0x4D82);
  unsigned x=(rawX-0xC9)&255,y=(rawY-0xD0)&255,ex=(endX-0xC9)&255,ey=(endY-0xD0)&255,dx=x>ex?x-ex:ex-x,dy=y>ey?y-ey:ey-y,hi=y>ey?y:ey,lo=y<ey?y:ey,f=0x40|(dy?0:0x80)|((hi&15)<(lo&15)?0x20:0);
  require(cpu->a==dy&&cpu->f.packed==f&&cpu->bc==(lo<<8|0x37)&&cpu->de==0xD201&&cpu->hl==target+4,"A12 common reader complete exact wrapped coordinates distances registers pointer",phase*256+frame);
  require(rd(c,0xC5CD)==17&&rd(c,0xC5D0)==frame%254&&rd(c,0xC5D7)==x&&rd(c,0xC5D8)==y&&rd(c,0xC5CB)==threshold&&rd(c,0xC5D1)==nextPhase&&rd(c,0xC5D9)==ex&&rd(c,0xC5DA)==ey&&rd(c,0xC5FD)==0x53&&rd(c,0xC5DD)==dx&&rd(c,0xC5DE)==dy&&rd(c,0xC5CF)==phase&&rd(c,0xC5CE)==frame&&rd(c,0xC5CC)==0x37&&rd(c,0xC5D6)==0x39&&rd(c,0xC5DB)==0x3C&&rd(c,0xC5DF)==0x5A,"A12 reader all phases frames common and FF FE lookahead skips exact fields guards",phase*256+frame);
  bool exact=rd(c,0xFFAD)==0x63&&rd(c,0xFFAE)==0&&rd(c,0xFF9D)==5&&rd(c,0xFF9E)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0;for(unsigned i=0;i<4;i++)exact&=rd(c,0x6000+i)==signatures[3][i];require(exact,"A12 common reader retains actual requested B mapping HRAM backup separate resident mirrors",phase*256+frame);
 }
 for(unsigned marker=0;marker<2;marker++)for(unsigned frame=0;frame<256;frame++)for(unsigned flags=0;flags<16;flags++){
  unsigned phase=(frame*37)&255,start=0xD201+4*frame;wr(c,start,marker?254:255);wr(c,0xC5CF,phase);wr(c,0xC5CE,frame);wr(c,0xC5D0,0x37);wr(c,0xC5CB,0x39);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBE37;cpu->hl=0xD000;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4D82;
  unsigned dest=marker?0x50C8:0x4FAF,steps=0;while(cpu->pc!=dest&&steps++<300)c->step(c);
  require(cpu->pc==dest&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==(marker?0x4DC5:0x4DBD)&&cpu->hl==start&&cpu->de==0xD201&&cpu->bc==0xBE37&&cpu->af==((marker?254:255)<<8|0xC0),"A12 initial FF FE real effect entry stack pointer registers flags",marker*4096+frame*16+flags);
  require(rd(c,0xC5CD)==17&&rd(c,0xC5CE)==frame&&rd(c,0xC5CF)==phase&&rd(c,0xC5D0)==0x37&&rd(c,0xC5CB)==0x39,"A12 initial effect prefix sets count before untouched frame fields",marker*4096+frame*16+flags);
 }
 bool untouched=true;for(unsigned plane=0;plane<2;plane++){wr(c,0xFF4F,plane);for(unsigned i=0;i<8192;i++)untouched&=rd(c,0x8000+i)==0xA5;}require(untouched,"A12 common reader and bounded effect prefixes leave both entire VRAM planes untouched",0);
 }
 { /* FE all byte request prefixes, then real upper-stream bodies. */
 struct GB *g=c->board;prepareA12EffectMapping(c,0x63);
 for(unsigned code=0;code<256;code++)for(unsigned flags=0;flags<16;flags++){
  const unsigned marker[]={254,code,0xA5,0x5A};for(unsigned i=0;i<4;i++)wr(c,0xD100+i,marker[i]);wr(c,0xC5CE,0x37);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0xD100;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x50C8;
  unsigned steps=0;while(cpu->pc!=0x24F&&steps++<100)c->step(c);
  require(cpu->pc==0x24F&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==0x50CE&&cpu->hl==0xD102&&cpu->af==(code<<8|flags<<4)&&cpu->bc==0xBE37&&cpu->de==0x1234&&rd(c,0xC5CE)==0x37,"A12 FE all request bytes flags exact actual audio boundary and unchanged index",code*16+flags);
 }
 for(unsigned code=0;code<256;code++)for(unsigned frame=0;frame<256;frame++){
  prepareA12EffectMapping(c,0x63);prepareA12EffectAudio(c);wr(c,0xD100,254);wr(c,0xD101,code);wr(c,0xD102,0xA5);wr(c,0xD103,0x5A);wr(c,0xD0FF,0x37);wr(c,0xD104,0x39);wr(c,0xC5CE,frame);unsigned flags=(code&15)<<4;
  cpu->af=0x5A00|flags;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0xD100;call(c,0x50C8);
  unsigned next=(frame+1)&255,f=(flags&0x10)|(next?0:0x80)|((frame&15)==15?0x20:0);bool exact=cpu->af==(next<<8|f)&&cpu->bc==0xBE37&&cpu->de==0x1234&&cpu->hl==0xD104&&rd(c,0xC5CE)==next&&rd(c,0xCF82)==(code>=128?0:code)&&rd(c,0xCF89)==(code>=128?0x11:0)&&rd(c,0xD0FF)==0x37&&rd(c,0xD104)==0x39&&rd(c,0xFFAB)==0x12&&rd(c,0xC113)==0x12&&rd(c,0xFFAD)==5&&rd(c,0xC115)==5;
  for(unsigned i=0;i<128;i++){unsigned expected=0x5A;if(code>=128&&i>=64&&i<80)expected=i==64?1:i==65?0xDD:i==68?8:0;exact&=rd(c,0xCF00+i)==expected;}
  require(exact,"A12 FE complete all request index bytes INC flags real upper install fields preserved lower slots mapper",code*256+frame);
 }
 }
 { /* FF complete all byte frame indices and flags, plus wrapped area shapes. */
 for(unsigned frame=0;frame<256;frame++)for(unsigned flags=0;flags<16;flags++)probeA12TileEffect(c,1,1,frame,flags<<4,flags&1,0,false,frame*16+flags);
 const unsigned widths[]={1,2,3,16,17,31},heights[]={1,3,2,16,17,9};
 for(unsigned shape=0;shape<6;shape++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++)probeA12TileEffect(c,widths[shape],heights[shape],255,0xF0,plane,lcd,true,4096+shape*4+plane*2+lcd);
 }
 { /* Complete reader with actual FF, FE and FF+FE bodies; no injected returns. */
 for(unsigned kind=1;kind<=3;kind++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++)for(unsigned wrap=0;wrap<2;wrap++){
  prepareA12EffectMapping(c,0x63);prepareA12EffectAudio(c);bool tile=kind&1,audio=kind&2;unsigned frame=wrap?255:0,effects=tile+audio,start=0xD201+frame*4,p=start;
  wr(c,0xD000,0);wr(c,0xD001,0xD2);wr(c,0xD200,7);
  const unsigned header[]={1,2,1,1,3,7,1};for(unsigned i=0;i<7;i++)wr(c,0xD800+i,header[i]);wr(c,0xD807,0x23);wr(c,0xD808,0x45);
  if(tile){const unsigned marker[]={255,0x5A,0,0xD8};for(unsigned i=0;i<4;i++)wr(c,p+i,marker[i]);p+=4;}
  if(audio){const unsigned marker[]={254,0x80,0xA5,0x5A};for(unsigned i=0;i<4;i++)wr(c,p+i,marker[i]);p+=4;}
  const unsigned records[]={2,0xCE,0xD9,4,1,0xD1,0xDD,0x53};for(unsigned i=0;i<8;i++)wr(c,p+i,records[i]);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}wr(c,0xFF4F,plane);wr(c,0xC5CF,0);wr(c,0xC5CE,frame);wr(c,0xC5E5,0xA5);wr(c,0xC5E7,0x5A);cpu->af=0x5AF0;cpu->bc=0xBE37;cpu->hl=0xD000;if(lcd)wr(c,0xFF40,0x91);call(c,0x4D82);
  bool exact=cpu->af==0x0440&&cpu->bc==(tile?0x0901:0x0937)&&cpu->de==(tile?0xD807:0xD201)&&cpu->hl==p+8&&rd(c,0xC5CE)==((frame+effects)&255)&&rd(c,0xC5CD)==7&&rd(c,0xC5D0)==2&&rd(c,0xC5D7)==5&&rd(c,0xC5D8)==9&&rd(c,0xC5D9)==8&&rd(c,0xC5DA)==13&&rd(c,0xC5DD)==3&&rd(c,0xC5DE)==4&&rd(c,0xC5D1)==1&&rd(c,0xC5FD)==0x53&&rd(c,0xC5CB)==4&&rd(c,0xFFAD)==0x63&&rd(c,0xC115)==0x63&&rd(c,0xFFAB)==0x12&&rd(c,0xC113)==0x12&&(rd(c,0xFF4F)&1)==plane;
  if(tile)exact&=rd(c,0xC5E5)==0&&rd(c,0xC5E7)==0&&rd(c,0xFF9D)==1&&(rd(c,0xC5F7)<<8|rd(c,0xC5F8))==0xD809;
  if(audio)exact&=rd(c,0xCF40)==1&&rd(c,0xCF41)==0xDD&&rd(c,0xCF44)==8&&rd(c,0xCF82)==0&&rd(c,0xCF89)==0x11;
  require(exact,"A12 full real marker chains wrap final register field mapper mirrors and scratch contracts",kind*8+plane*4+lcd*2+wrap);
  wr(c,0xFF40,0);exact=true;for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)exact&=rd(c,0x8000+i)==(tile&&i==0x1841?(bank?0x45:0x23):0xA5);}require(exact,"A12 full marker chain both complete VRAM planes exact original effects",kind*8+plane*4+lcd*2+wrap);
 }
 }
 { /* Complete guard returns or actual first-call boundaries of whole controller. */
 struct GB *g=c->board;wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned family=0;family<2;family++)for(unsigned first=0;first<256;first++)for(unsigned second=0;second<256;second++)for(unsigned flags=0;flags<16;flags++){
  unsigned mode=family?255:first,phase=family?0x37:second,busy=family?second:1,edge=family?first:0;
  bool reset=!family&&mode&&mode!=255&&phase==1,hide=family&&!busy;unsigned target=reset?0x4CFD:hide?0x4CB8:0xC100;
  unsigned a,f;if(family){a=busy;f=busy?0x20:0xA0;}else if(!mode){a=0;f=0xA0;}else if(mode==255){a=1;f=0x20;}else if(phase!=1){a=phase;f=0x40|((phase&15)<1?0x20:0)|(phase<1?0x10:0);}else{a=2;f=0xC0;}
  wr(c,0xC601,mode);wr(c,0xC5CF,phase);wr(c,0xC1B8,busy);wr(c,0xFF97,edge);wr(c,0xC1C2,0x5A);wr(c,0xC73A,0x37);wr(c,0xC73B,0x39);wr(c,0xC600,0x3C);wr(c,0xC602,0x5A);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4B70;
  unsigned steps=0;while(cpu->pc!=target&&steps++<200)c->step(c);
  require(cpu->pc==target&&cpu->sp==(reset||hide?0xCFFC:0xD000)&&(!(reset||hide)||(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==(reset?0x4B88:0x4BC2))&&cpu->af==(a<<8|f)&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0x5678,"A12 whole text controller exhaustive guards return or actual reset hide boundary registers flags",family*1048576+first*4096+second*16+flags);
  require(rd(c,0xC601)==mode&&rd(c,0xC5CF)==(reset?2:phase)&&rd(c,0xC1C2)==((edge&1)?0:0x5A)&&rd(c,0xC73A)==0x37&&rd(c,0xC73B)==0x39&&rd(c,0xC600)==0x3C&&rd(c,0xC602)==0x5A,"A12 whole controller mode phase edge clear busy gate exact fields and guards",family*1048576+first*4096+second*16+flags);
 }
 /* Forced suffix entries prove only local contracts after unexecuted callees. */
 for(unsigned family=0;family<3;family++)for(unsigned value=0;value<256;value++)for(unsigned flags=0;flags<16;flags++){
  unsigned target=family==0?(value==1?0x5C2F:value==2?0x4C88:0xC100):family==1?0x4CFD:value?0x5C55:0xC100;
  unsigned a=family==0?(value==2?0:value):family==1?1:value,f=family==0?(value==1||value==2?0xC0:0x40|((value&15)<2?0x20:0)|(value<2?0x10:0)):family==1?flags<<4:value?0x40:0xC0;
  wr(c,0xC601,family==0?value:255);wr(c,0xC5CF,family==1?value:0x37);wr(c,0xC73A,0x5A);wr(c,0xC73B,family==2?value:0x39);wr(c,0xC1C2,0x3C);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=family==0?0x4B88:family==1?0x4BC2:0x4BCA;
  unsigned steps=0;while(cpu->pc!=target&&steps++<200)c->step(c);
  bool nested=(family==0&&value==2)||family==1||(family==2&&value);unsigned ret=family==0?0x4B9F:family==1?0x4BCA:0x4BD7;
  require(cpu->pc==target&&cpu->sp==(nested?0xCFFC:family==0&&value==1?0xCFFE:0xD000)&&(!nested||(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==ret)&&cpu->af==(a<<8|f)&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0x5678,"A12 text forced suffix exact local branch call tail stack registers flags",family*4096+value*16+flags);
  require(rd(c,0xC601)==(family==0?value:family==1?255:0)&&rd(c,0xC5CF)==(family==1?1:0x37)&&rd(c,0xC73A)==(family==0&&value==2?1:0x5A)&&rd(c,0xC73B)==(family==2?value:0x39)&&rd(c,0xC1C2)==0x3C,"A12 local suffix writes mode phase accelerated counter flag and pending guard only",family*4096+value*16+flags);
 }
 for(unsigned a=0;a<256;a++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC73B,0xA5);wr(c,0xC73A,0x37);wr(c,0xC601,0x39);cpu->af=a<<8|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x4BD7);
  require(cpu->af==flags<<4&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0x5678&&rd(c,0xC73B)==0&&rd(c,0xC73A)==0x37&&rd(c,0xC601)==0x39,"A12 post unexecuted5C55 suffix clears pending byte preserves every incoming flag",a*16+flags);
 }
 }
 { /* Forced table scanner fragment, raw indices, and complete pending tails. */
 struct GB *g=c->board;prepareA12EffectMapping(c,0x63);
 const unsigned thresholds[]={0,2,8,12,16,20,24,25,28,32,36,40,44,48,49,52,56,60,64,68,72};
 const unsigned pointers[]={0x55B2,0x572F,0x57A6,0x57BB,0x5850,0x58B4,0x58E5,0x591F,0x594A,0x5960,0x5975,0x59B8,0x5A0E,0x5A33,0x5A6C,0x5A96,0x5AD2,0x5B2D,0x5B67,0x5B78,0x5BB0};
 for(unsigned value=0;value<256;value++)for(unsigned flags=0;flags<16;flags++){
  unsigned row=0;while(row<21&&thresholds[row]!=value)row++;unsigned target=row<21?0x5C04:0xC100;
  wr(c,0xC705,value);wr(c,0xC73B,0x39);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x5BEB;
  unsigned steps=0;while(cpu->pc!=target&&steps++<1000)c->step(c);
  require(cpu->pc==target&&cpu->sp==(row<21?0xCFFE:0xD000)&&cpu->hl==0x56AD+6*row&&cpu->de==6&&cpu->bc==((row<21?value:72)<<8|row+1)&&cpu->af==((row<21?value:255)<<8|0xC0)&&rd(c,0xC705)==value&&rd(c,0xC73B)==0x39,"A12 forced scanner all bytes flags first sentinel and exact 21 thresholds",value*16+flags);
 }
 for(unsigned pending=0;pending<256;pending++)for(unsigned flags=0;flags<16;flags++){
  unsigned index=(pending-1)&255,address=0x56AD+6*index;
  wr(c,0xC73B,pending);wr(c,0xC601,0x37);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x5C55;
  unsigned steps=0;while(cpu->pc!=0x5C66&&steps++<300)c->step(c);
  require(cpu->pc==0x5C66&&cpu->sp==0xCFFE&&cpu->af==(index<<8|0x80)&&cpu->bc==0xBEEF&&cpu->de==0x56AD&&cpu->hl==address+3&&rd(c,0xC73B)==pending&&rd(c,0xC601)==0x37,"A12 raw pending action offset all bytes flags no clamp before read",pending*16+flags);
  unsigned pointer=rd(c,address+4)|(rd(c,address+5)<<8);wr(c,0xC1B3,0x3C);wr(c,0xC1B4,0x5A);wr(c,0xC1B8,0x39);cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x5C37);
  require(cpu->af==0xFF80&&cpu->bc==0xBEEF&&cpu->de==1&&cpu->hl==0xC1B8&&rd(c,0xC1AB)==(pointer&255)&&rd(c,0xC1AC)==pointer>>8&&rd(c,0xC1B8)==1&&rd(c,0xC1B3)==0&&rd(c,0xC1B4)==0&&rd(c,0xC601)==255&&rd(c,0xC73B)==pending,"A12 forced message suffix actual queue all raw bytes flags no interpreter execution",pending*16+flags);
 }
 for(unsigned row=0;row<21;row++)if(row!=6&&row!=13&&row!=20)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC73B,row+1);wr(c,0xC5A3,0x37);wr(c,0xC706,0x39);cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;call(c,0x5C55);
  require(cpu->af==0x00C0&&cpu->bc==0xBEEF&&cpu->de==0x56AD&&cpu->hl==0x56B0+6*row&&rd(c,0xC5A3)==0x37&&rd(c,0xC706)==0x39,"A12 complete zero-action rows preserve state",row*16+flags);
 }
 for(unsigned action=1;action<=3;action++)for(unsigned state=0;state<256;state++)for(unsigned flags=0;flags<16;flags++){
  unsigned row=action==1?6:action==2?13:20,resource=0x5332+action*128,last=0;
  wr(c,0xC73B,row+1);wr(c,0xC5A3,state);wr(c,0xC706,0x39);for(unsigned i=0;i<3;i++)wr(c,0xC708+i,0x5A);wr(c,0xC214,0x37);wr(c,0xC738,0x3C);wr(c,0xC213,0x3C);wr(c,0xC1C4,0x3C);wr(c,0xC21F,0x37);wr(c,0xC221,0x39);
  unsigned colors[64];for(unsigned i=0;i<64;i++)colors[i]=rd(c,resource+2*i)|(rd(c,resource+2*i+1)<<8);
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x5C55);
  bool exact=true;for(unsigned i=0;i<192;i++){unsigned component=(colors[i/3]>>(5*(i%3)))&31,base=component*2048,delta=(31-component)*256;last=delta;exact&=rd(c,0xC2A2+2*i)==(base&255)&&rd(c,0xC2A3+2*i)==base>>8&&rd(c,0xC422+2*i)==(delta&255)&&rd(c,0xC423+2*i)==delta>>8;}
  unsigned next=(state+1)&255,f=(next?0:0x80)|((state&15)==15?0x20:0);
  exact&=cpu->af==(next<<8|f)&&cpu->bc==0&&cpu->de==last&&cpu->hl==0x08F4&&rd(c,0xC5A3)==next&&rd(c,0xC5A2)==2&&rd(c,0xC220)==8&&rd(c,0xC21F)==0x37&&rd(c,0xC221)==0x39&&rd(c,0xC706)==(action==3?0x39:action)&&rd(c,0xC214)==(action==3?5:4)&&rd(c,0xC738)==0&&rd(c,0xC213)==0&&rd(c,0xC1C4)==0&&rd(c,0xC73B)==row+1;
  for(unsigned i=0;i<3;i++)exact&=rd(c,0xC708+i)==(action==3||i==action-1?6:0x5A);
  require(exact,"A12 complete three real dispatcher actions all state bytes flags actual palettes transition and INC",action*4096+state*16+flags);
 }
 for(unsigned row=0;row<21;row++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++)for(unsigned flags=0;flags<16;flags++){
  prepareA12EffectMapping(c,0x63);prepareA12EffectAudio(c);
  for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}wr(c,0xFF4F,plane);wr(c,0xC1B5,0);wr(c,0xC1B6,0x98);wr(c,0xC1A3,0x23);wr(c,0xC1C2,0x3C);wr(c,0xC73B,row+1);wr(c,0xC601,1);wr(c,0xC1B8,0x39);cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;if(lcd)wr(c,0xFF40,0x91);callWithLimit(c,0x5C2F,2000000);
  bool exact=cpu->af==0xFF80&&cpu->bc==0&&cpu->de==1&&cpu->hl==0xC1B8&&rd(c,0xC1AB)==(pointers[row]&255)&&rd(c,0xC1AC)==pointers[row]>>8&&rd(c,0xC601)==255&&rd(c,0xC73B)==row+1&&rd(c,0xC1B8)==1&&rd(c,0xC1B3)==0&&rd(c,0xC1B4)==0&&rd(c,0xC1C2)==0&&rd(c,0xC5A5)==0&&rd(c,0xC5C4)==0&&rd(c,0xFF40)==(lcd?0xF1:0x60)&&(rd(c,0xFF4F)&1)==plane&&rd(c,0xC113)==0x12&&rd(c,0xC115)==5;
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){unsigned y=i>=0x1800?(i-0x1800)/32:256,x=i%32,expected=0xA5;if(y<6&&x<20)expected=bank?0x23:0x6C+(y==0?0:y==5?6:3)+(x==0?0:x==19?2:1);exact&=rd(c,0x8000+i)==expected;}}
  require(exact,"A12 complete pending text 21 original pointers all flags both VBK LCD states exact whole VRAM",row*64+plane*32+lcd*16+flags);
 }
 }
 { /* Whole scanner entry; raw variant prefixes do not establish validity. */
 struct GB *g=c->board;prepareA12EffectMapping(c,0x63);
 const unsigned thresholds[]={0,2,8,12,16,20,24,25,28,32,36,40,44,48,49,52,56,60,64,68,72};
 const unsigned values[]={0,1,2,3,4,5,5,0,1,2,3,4,5,5,0,1,2,3,4,5,6};
 for(unsigned variant=0;variant<256;variant++)for(unsigned flags=0;flags<16;flags++){
  unsigned value=(variant*37+flags*13)&255;wr(c,0xC708+variant,value);wr(c,0xC706,variant);wr(c,0xC5A4,0x5A);wr(c,0xC5A8,0x39);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x5BDA;
  unsigned steps=0;while(cpu->pc!=0x5BEB&&steps++<100)c->step(c);
  require(cpu->pc==0x5BEB&&cpu->sp==0xCFFE&&cpu->af==(value<<8|(flags<<4&0x80))&&cpu->bc==0xBEEF&&cpu->de==variant&&cpu->hl==0xC708+variant&&rd(c,0xC5A8)==variant&&rd(c,0xC5A4)==value&&rd(c,0xC706)==variant,"A12 complete initial scanner prefix all raw variant bytes flags no clamp",variant*16+flags);
 }
 for(unsigned variant=0;variant<4;variant++)for(unsigned input=0;input<256;input++)for(unsigned flags=0;flags<16;flags++){
  unsigned row=0;while(row<21&&thresholds[row]!=input)row++;bool found=row<21,select=found&&row%7>=1&&row%7<=5;unsigned initial[4];for(unsigned i=0;i<4;i++){initial[i]=(37+i*29+flags*13)&255;wr(c,0xC708+i,initial[i]);}
  wr(c,0xC706,variant);wr(c,0xC705,input);wr(c,0xC73B,0x39);wr(c,0xC738,0x5A);wr(c,0xC5A4,0x3C);wr(c,0xC5A8,0x3C);wr(c,0xC707,0x37);wr(c,0xC70C,0x39);
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x5BDA);
  unsigned a=found?0:255,f=found?(select?0x80:0x70):0xC0,bc=found?(input<<8|row+1):0x4816,hl=found?0x56AE + 6*row:0x572B;
  bool exact=cpu->af==(a<<8|f)&&cpu->bc==bc&&cpu->de==(found?variant:6)&&cpu->hl==hl&&rd(c,0xC705)==(found?input+1:input)&&rd(c,0xC73B)==(found?row+1:0x39)&&rd(c,0xC5A8)==(select?3:variant)&&rd(c,0xC5A4)==(found?values[row]:initial[variant])&&rd(c,0xC738)==(select?0:0x5A)&&rd(c,0xC706)==variant&&rd(c,0xC707)==0x37&&rd(c,0xC70C)==0x39;
  for(unsigned i=0;i<4;i++)exact&=rd(c,0xC708+i)==(found&&i==variant?values[row]:initial[i]);
  require(exact,"A12 whole pending scanner original21 records all progress bytes four variants flags match no-match state and registers",variant*4096+input*16+flags);
 }
 }
 { /* Original dispatcher full byte commands and bounded raw color pointer suffix. */
 struct GB *g=c->board;prepareA12EffectMapping(c,0x63);
 for(unsigned variant=0;variant<4;variant++)for(unsigned command=0;command<256;command++)for(unsigned flags=0;flags<16;flags++)probeA12ResourceCommand(c,command,variant,(command*37+flags*13)&255,flags<<4,variant*4096+command*16+flags);
 const unsigned commands[]={0xF1,0xF2,0xF3,0xF4,0xF5,0xF6,0xF7,0xFE};
 for(unsigned variant=0;variant<4;variant++)for(unsigned cmd=0;cmd<8;cmd++)for(unsigned state=0;state<256;state++)probeA12ResourceCommand(c,commands[cmd],variant,state,(state&15)<<4,16384+variant*2048+cmd*256+state);
 for(unsigned variant=0;variant<256;variant++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5A8,variant);wr(c,0xC213,0x37);wr(c,0xC1C4,0x39);wr(c,0xC5A3,0x3C);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x4B4C;
  unsigned steps=0;while(cpu->pc!=0x17A&&steps++<300)c->step(c);
  unsigned f=0x80|((0x3B2+((variant*128)&0xFFF))>0xFFF?0x20:0);
  require(cpu->pc==0x17A&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==0x4B68&&cpu->af==(0x0400|f)&&cpu->bc==0xBEEF&&cpu->de==0x53B2&&cpu->hl==0x53B2+128*variant&&rd(c,0xC213)==0&&rd(c,0xC1C4)==0&&rd(c,0xC5A3)==0x3C&&rd(c,0xC5A8)==variant,"A12 forced color suffix all raw variants flags pointer no clamp actual transition boundary",variant*16+flags);
 }
 }
 { /* Full input guard entry, exact first callee; no fake returns. */
 struct GB *g=c->board;prepareA12EffectMapping(c,0x63);
 for(unsigned mode=0;mode<256;mode++)for(unsigned edge=0;edge<256;edge++)for(unsigned flags=0;flags<16;flags++){
  bool audio=mode==1&&(edge&3);unsigned target=audio?0x24F:0xC100,a=mode!=1?mode:audio?(edge&1?0x9D:0x9E):edge,f=mode!=1?0x40|((mode&15)<1?0x20:0)|(mode<1?0x10:0):audio?0x20:0xA0;
  wr(c,0xC600,mode);wr(c,0xFF97,edge);wr(c,0xC732,0x37);wr(c,0xC213,0x39);wr(c,0xC214,0x3C);wr(c,0xC5A8,0x5A);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x470F;
  unsigned steps=0;while(cpu->pc!=target&&steps++<100)c->step(c);
  require(cpu->pc==target&&cpu->sp==(audio?0xCFFC:0xD000)&&(!audio||(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==(edge&1?0x473F:0x4728))&&cpu->af==(a<<8|f)&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0x5678,"A12 input full entry all mode edge bytes flags priority returns actual audio boundary",mode*4096+edge*16+flags);
  require(rd(c,0xC600)==mode&&rd(c,0xFF97)==edge&&rd(c,0xC732)==0x37&&rd(c,0xC213)==0x39&&rd(c,0xC214)==0x3C&&rd(c,0xC5A8)==0x5A,"A12 input entry guards no writes before real audio call",mode*4096+edge*16+flags);
 }
 const unsigned entries[]={0x473F,0x4764,0x485A,0x4940},tables[]={0x475E,0x477A,0x4870,0x4956},stops[]={0x475C,0x4778,0x486E,0x4954},returns[]={0x475D,0x4779,0x486F,0x4955};
 for(unsigned family=0;family<4;family++)for(unsigned index=0;index<256;index++)for(unsigned flags=0;flags<16;flags++){
  unsigned offset=(index*2)&255,target=rd(c,tables[family]+offset)|(rd(c,tables[family]+offset+1)<<8);
  wr(c,0xC5A8,family?0x37:index);wr(c,0xC214,family?index:0x39);wr(c,0xC732,0x5A);wr(c,0xFF97,0xA5);wr(c,0xC600,1);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=entries[family];
  unsigned steps=0;while(cpu->pc!=stops[family]&&steps++<100)c->step(c);
  require(cpu->pc==stops[family]&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==returns[family]&&cpu->af==(offset<<8|(offset?0:0x80))&&cpu->bc==0xBEEF&&cpu->de==target&&cpu->hl==target&&rd(c,0xC732)==(family?0x5A:0x39)&&rd(c,0xFF97)==(family?0xA5:0)&&rd(c,0xC600)==1,"A12 raw nested dispatcher all indices flags original pushed return stop before arbitrary target",family*4096+index*16+flags);
 }
 for(unsigned family=0;family<4;family++)for(unsigned a=0;a<256;a++)for(unsigned flags=0;flags<16;flags++){
  cpu->af=a<<8|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,returns[family]);require(cpu->af==(a<<8|flags<<4)&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0x5678,"A12 nested return labels preserve every AF and register",family*4096+a*16+flags);
 }
 /* Confirm executes actual upper audio, stopping before selected variant. */
 const unsigned targets[]={0x4764,0x485A,0x4940};
 for(unsigned variant=0;variant<3;variant++)for(unsigned state=0;state<256;state++)for(unsigned flags=0;flags<16;flags++){
  prepareA12EffectMapping(c,0x63);prepareA12EffectAudio(c);wr(c,0xC600,1);wr(c,0xFF97,3);wr(c,0xC214,state);wr(c,0xC5A8,variant);wr(c,0xC732,0x37);wr(c,0xC213,0x39);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x470F;
  unsigned steps=0;while(cpu->pc!=0x475C&&steps++<10000)c->step(c);
  require(cpu->pc==0x475C&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==0x475D&&cpu->hl==targets[variant]&&cpu->de==targets[variant]&&cpu->bc==0xBEEF&&cpu->af==(variant*2<<8|(variant?0:0x80))&&rd(c,0xC732)==state&&rd(c,0xFF97)==0&&rd(c,0xC600)==1&&rd(c,0xC213)==0x39&&rd(c,0xCF82)==0&&rd(c,0xCF89)==0x11&&rd(c,0xC113)==0x12&&rd(c,0xC115)==5,"A12 confirm real audio all states flags three original variant targets priority original stack",variant*4096+state*16+flags);
 }
 /* Complete cancellation with real hide/two-plane copy, synthetic source. */
 for(unsigned edge=0;edge<256;edge++)if(!(edge&1)&&(edge&2))for(unsigned flags=0;flags<16;flags++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++){
  prepareA12EffectMapping(c,0x63);prepareA12EffectAudio(c);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++)wr(c,0x8000+i,0xA5);}wr(c,0xFF70,7);for(unsigned i=0;i<320;i++)wr(c,0xD000+i,(i*13+edge)&255);wr(c,0xD140,0x37);wr(c,0xFF70,2);wr(c,0xFF4F,plane);wr(c,0xC600,1);wr(c,0xFF97,edge);wr(c,0xC213,0x39);wr(c,0xC732,0x3C);wr(c,0xC214,0x37);wr(c,0xC5A8,0x39);cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;if(lcd)wr(c,0xFF40,0xF1);callWithLimit(c,0x470F,2000000);
  bool exact=cpu->af==0x0080&&rd(c,0xC600)==0&&rd(c,0xFF97)==0&&rd(c,0xC213)==0&&rd(c,0xC732)==0x3C&&rd(c,0xC214)==0x37&&rd(c,0xC5A8)==0x39&&rd(c,0xFF40)==(lcd?0x91:0)&&rd(c,0xCF82)==0&&rd(c,0xC113)==0x12&&rd(c,0xC115)==5&&(rd(c,0xFF70)&7)==2&&(rd(c,0xFF4F)&1)==0;
  wr(c,0xFF40,0);for(unsigned bank=0;bank<2;bank++){wr(c,0xFF4F,bank);for(unsigned i=0;i<8192;i++){unsigned y=i>=0x1C00?(i-0x1C00)/32:256,x=i%32,expected=y<8&&x<20?((bank*160+y*20+x)*13+edge)&255:0xA5;exact&=rd(c,0x8000+i)==expected;}}wr(c,0xFF70,7);for(unsigned i=0;i<320;i++)exact&=rd(c,0xD000+i)==((i*13+edge)&255);exact&=rd(c,0xD140)==0x37;wr(c,0xFF70,2);
  require(exact,"A12 complete cancel every bit1 edge flags both VBK LCD actual audio hide full VRAM source guards",edge*64+flags*4+plane*2+lcd);
 }
 }
 { /* Complete original action bodies and whole input/variant/action integrations. */
 for(unsigned v=0;v<3;v++)for(unsigned action=0;action<6;action++)for(unsigned value=0;value<256;value++)probeA12InputAction(c,v,action,value,(value&15)<<4,0,0,false,false,v*1536+action*256+value);
 const unsigned values[]={0,1,2,3,5,6,7,255};
 for(unsigned v=0;v<3;v++)for(unsigned action=0;action<6;action++)for(unsigned val=0;val<8;val++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++)probeA12InputAction(c,v,action,values[val],val<<4,plane,lcd,true,true,4608+v*192+action*32+val*4+plane*2+lcd);
 }
 { /* Complete position copies and emissions; wrapper prefixes/suffixes explicit. */
 struct GB *g=c->board;prepareA12EffectMapping(c,0x63);
 for(unsigned family=0;family<2;family++)for(unsigned x=0;x<256;x++)for(unsigned y=0;y<256;y++){
  wr(c,family?0xC5EB:0xC5D7,x);wr(c,family?0xC5EC:0xC5D8,y);wr(c,family?0xC5E9:0xC5D5,0x3C);wr(c,family?0xC5EA:0xC5D6,0x39);cpu->af=0x5A00|((x^y)&15)<<4;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x5678;call(c,family?0x51E5:0x4E65);
  require(cpu->af==(y<<8|0x40|(y?0:0x80))&&cpu->bc==0x37&&cpu->de==0x1234&&cpu->hl==0x5678&&rd(c,family?0xC5E9:0xC5D5)==x&&rd(c,family?0xC5EA:0xC5D6)==y&&rd(c,family?0xC5EB:0xC5D7)==x&&rd(c,family?0xC5EC:0xC5D8)==y,"A12 complete both position copies every coordinate pair varied flags registers guards",family*65536+x*256+y);
 }
 const unsigned entries[]={0x4A36,0x4A66,0x4A8A,0x4AAE},sels[]={0x61,0x63,0x65,0x66},returns[]={0x4A43,0x4A73,0x4A97,0x4ABB},suffix[]={0x4A58,0x4A7C,0x4AA0,0x4AC4};
 for(unsigned v=0;v<4;v++)for(unsigned old=0;old<256;old++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC21C,0x37);wr(c,0xC21D,old);wr(c,0xC5CC,0x39);wr(c,0xC73A,0x3C);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=entries[v];unsigned target=v?0x4D54:0x50DF,steps=0;while(cpu->pc!=target&&steps++<100)c->step(c);
  require(cpu->pc==target&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==returns[v]&&cpu->af==flags<<4&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0x5678&&rd(c,0xC21C)==sels[v]&&rd(c,0xC21D)==0&&rd(c,0xC5CC)==0x39&&rd(c,0xC73A)==0x3C,"A12 wrapper complete entry all prior request high bytes flags actual first callee only",v*4096+old*16+flags);
 }
 for(unsigned v=0;v<3;v++)for(unsigned counter=0;counter<256;counter++)for(unsigned accel=0;accel<256;accel++){
  unsigned next=(counter+(accel?4:1))&255,f=accel?((next?0:0x80)|(((next-1)&15)==15?0x20:0)):0xA0,flags=((counter^accel)&15)<<4;
  wr(c,0xC5CC,counter);wr(c,0xC73A,accel);wr(c,0xC5CB,0x37);wr(c,0xC5CD,0x39);cpu->af=0x5A00|flags;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,suffix[v]);
  require(cpu->af==(accel<<8|f)&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0xC5CC&&rd(c,0xC5CC)==next&&rd(c,0xC73A)==accel&&rd(c,0xC5CB)==0x37&&rd(c,0xC5CD)==0x39,"A12 forced wrapper suffix all counter acceleration bytes wrap exact fields flags registers",v*65536+counter*256+accel);
 }
 for(unsigned counter=0;counter<256;counter++)for(unsigned flags=0;flags<16;flags++){
  unsigned next=(counter+1)&255,f=(flags<<4&0x10)|(next?0:0x80)|((counter&15)==15?0x20:0);wr(c,0xC5CC,counter);wr(c,0xC73A,0x37);cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,suffix[3]);require(cpu->af==(0x5A00|f)&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0xC5CC&&rd(c,0xC5CC)==next&&rd(c,0xC73A)==0x37,"A12 variant3 forced suffix every counter flag preserves carry ignores acceleration",counter*16+flags);
 }
 const unsigned avail[]={0,1,40,255},counts[]={0,1,3,255};
 for(unsigned family=0;family<2;family++)for(unsigned count=0;count<256;count++)for(unsigned a=0;a<4;a++)probeA12OAMEmission(c,family,avail[a],count,(count*37+a*13)&255,(count*19+a)&255,(count*29+family)&255,(count&15)<<4,family*1024+count*4+a);
 for(unsigned family=0;family<2;family++)for(unsigned available=0;available<256;available++)for(unsigned count=0;count<4;count++)probeA12OAMEmission(c,family,available,counts[count],(available*37)&255,available,255-available,(available&15)<<4,2048+family*1024+available*4+count);
 }
 { /* Complete division, recurrence and movement; no natural interpolation claim. */
 prepareA12EffectMapping(c,0x63);
 for(unsigned a=0;a<256;a++)for(unsigned divisor=0;divisor<256;divisor++)for(unsigned flags=0;flags<16;flags++){
  unsigned q=divisor?a/divisor:255,r=divisor?a%divisor:a,f=a<divisor?0x40|((a&15)<(divisor&15)?0x20:0)|0x10:0xC0|((q&1)?0:0x10);
  cpu->af=a<<8|flags<<4;cpu->bc=0xBE00|divisor;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x4F4F);
  require(cpu->af==(r<<8|f)&&cpu->bc==(0xBE00|divisor)&&cpu->de==0x1234&&cpu->hl==(q<<8|r),"A12 complete division all dividend divisor flag bytes zero divisor and early return",a*4096+divisor*16+flags);
 }
 for(unsigned distance=0;distance<256;distance++)for(unsigned divisor=0;divisor<256;divisor++)probeA12StepCalculation(c,distance,255-distance,divisor,1,((distance^divisor)&15)<<4,distance*256+divisor);
 for(unsigned counter=0;counter<256;counter++)for(unsigned divisor=0;divisor<256;divisor++)probeA12StepCalculation(c,(counter*37+divisor)&255,(counter*19+divisor*13)&255,divisor,counter,((counter^divisor)&15)<<4,65536+counter*256+divisor);
 for(unsigned family=0;family<3;family++)for(unsigned current=0;current<256;current++)for(unsigned target=0;target<256;target++){
  unsigned x=family==1?73:current,tx=family==1?73:target,y=family==0?73:family==1?current:target,ty=family==0?73:family==1?target:current,counter=family==2?1+((current^target)&3):1,divisor=(current+target)&255;
  probeA12Movement(c,x,y,tx,ty,divisor,counter,((current^target)&15)<<4,family*65536+current*256+target);
 }
 /* Real common tick movement branch and complete variants1/2/3 with no OAM slots. */
 for(unsigned v=1;v<4;v++)for(unsigned counter=0;counter<4;counter++)for(unsigned accel=0;accel<256;accel++){
  unsigned x=(accel*37)&255,y=(accel*19)&255,tx=(x+23)&255,ty=(y-17)&255,dx=x>tx?x-tx:tx-x,dy=y>ty?y-ty:ty-y,divisor=7;struct A12StepModel sx=a12StepModel(dx,divisor,counter),sy=a12StepModel(dy,divisor,counter);unsigned nx=(x<tx?x+sx.q:x-sx.q)&255,ny=(y<ty?y+sy.q:y-sy.q)&255,entry=v==1?0x4A66:v==2?0x4A8A:0x4AAE,sel=v==1?0x63:v==2?0x65:0x66,next=(counter+(v<3&&accel?4:1))&255,f=v<3?(accel?((next?0:0x80)|(((next-1)&15)==15?0x20:0)):0xA0):(next?0:0x80)|((counter&15)==15?0x20:0);
  prepareA12EffectMapping(c,0x63);wr(c,0xC5D7,x);wr(c,0xC5D8,y);wr(c,0xC5D9,tx);wr(c,0xC5DA,ty);wr(c,0xC5DD,dx);wr(c,0xC5DE,dy);wr(c,0xC5CB,divisor);wr(c,0xC5CC,counter);wr(c,0xC73A,accel);wr(c,0xC1C7,0);wr(c,0xC5F5,0x37);wr(c,0xC5CE,0x39);wr(c,0xC5CF,0x3C);cpu->af=0x5A00|(accel&15)<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;callWithLimit(c,entry,200000);
  require(cpu->af==((v<3?accel:0)<<8|f)&&cpu->bc==divisor&&cpu->de==0x1234&&cpu->hl==0xC5CC&&rd(c,0xC5D7)==nx&&rd(c,0xC5D8)==ny&&rd(c,0xC5D5)==nx&&rd(c,0xC5D6)==ny&&rd(c,0xC5CC)==next&&rd(c,0xC5CB)==divisor&&rd(c,0xC73A)==accel&&rd(c,0xC5F5)==0&&rd(c,0xC1C7)==0&&rd(c,0xC5CE)==0x39&&rd(c,0xC5CF)==0x3C&&rd(c,0xC21C)==sel&&rd(c,0xC21D)==0&&rd(c,0xFFAD)==sel&&rd(c,0xC115)==5&&rd(c,0xFF9D)==5,"A12 complete variants1to3 real tick movement position emitter-zero and counter no fake returns",v*1024+counter*256+accel);
 }
 }
 { /* Wrapped coordinate offsets and independent unsigned distances. */
 wr(c,0xFF40,0);wr(c,0xFF70,2);wr(c,0x27FF,0x12);wr(c,0x2800,0);
 for(unsigned value=0;value<256;value++)for(unsigned flags=0;flags<16;flags++){
  unsigned in[]={value,(value*37)&255,(value*73)&255,(value*109)&255};
  wr(c,0xC5EB,in[0]);wr(c,0xC5EC,in[1]);wr(c,0xC5ED,in[2]);wr(c,0xC5EE,in[3]);wr(c,0xC5EA,0x37);wr(c,0xC5EF,0x39);
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x51FA);
  unsigned a=(in[3]-0xD0)&255,f=0x40|(a?0:0x80)|(in[3]<0xD0?0x10:0);
  require(cpu->a==a&&cpu->f.packed==f&&cpu->bc==0xD037&&cpu->de==0x1234&&cpu->hl==0x5678&&rd(c,0xC5EB)==((in[0]-0xC9)&255)&&rd(c,0xC5EC)==((in[1]-0xD0)&255)&&rd(c,0xC5ED)==((in[2]-0xC9)&255)&&rd(c,0xC5EE)==a&&rd(c,0xC5EA)==0x37&&rd(c,0xC5EF)==0x39,"A12 secondary offsets all byte inputs flags wrap exact fields and guards",value*16+flags);
 }
 for(unsigned x=0;x<256;x++)for(unsigned y=0;y<256;y++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5EB,x);wr(c,0xC5ED,y);wr(c,0xC5EC,y);wr(c,0xC5EE,x);wr(c,0xC5F0,0x37);wr(c,0xC5F3,0x39);
  cpu->af=0x5A00|flags<<4;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x5223);
  unsigned hi=x>y?x:y,lo=x<y?x:y,d=hi-lo,f=0x40|(d?0:0x80)|((hi&15)<(lo&15)?0x20:0);
  require(cpu->a==d&&cpu->f.packed==f&&cpu->bc==(lo<<8|0x37)&&cpu->de==0x1234&&cpu->hl==0x5678&&rd(c,0xC5F1)==d&&rd(c,0xC5F2)==d&&rd(c,0xC5EB)==x&&rd(c,0xC5ED)==y&&rd(c,0xC5EC)==y&&rd(c,0xC5EE)==x&&rd(c,0xC5F0)==0x37&&rd(c,0xC5F3)==0x39,"A12 secondary distances all unsigned byte pairs flags both comparison branches",x*4096+y*16+flags);
 }
 }

 { /* Secondary steps/movement execute actual shared division. */
 prepareA12EffectMapping(c,0x63);
 for(unsigned distance=0;distance<256;distance++)for(unsigned divisor=0;divisor<256;divisor++)probeA12SecondaryStepCalculation(c,distance,255-distance,divisor,1,((distance^divisor)&15)<<4,distance*256+divisor);
 for(unsigned counter=0;counter<256;counter++)for(unsigned divisor=0;divisor<256;divisor++)probeA12SecondaryStepCalculation(c,(counter*37+divisor)&255,(counter*19+divisor*13)&255,divisor,counter,((counter^divisor)&15)<<4,65536+counter*256+divisor);
 for(unsigned family=0;family<3;family++)for(unsigned current=0;current<256;current++)for(unsigned target=0;target<256;target++){
  unsigned x=family==1?73:current,tx=family==1?73:target,y=family==0?73:family==1?current:target,ty=family==0?73:family==1?target:current;
  probeA12SecondaryMovement(c,x,y,tx,ty,(current+target)&255,family==2?1+((current^target)&3):1,((current^target)&15)<<4,family*65536+current*256+target);
 }
 }
 { /* Synthetic records test actual secondary reader, including bounded marker skips. */
 prepareA12EffectMapping(c,0x63);
 for(unsigned i=0;i<128;i++){wr(c,0xD000+2*i,0);wr(c,0xD001+2*i,0xD2);}wr(c,0xD200,17);
 for(unsigned phase=0;phase<256;phase++)for(unsigned frame=0;frame<256;frame++){
  unsigned raw=0xD201+4*frame,p=phase%4,q=frame%4,skip=p==3?8:p?4:0,ns=q==3?8:q?4:0,start=raw+skip,target=start+4+ns;
  unsigned rx=(frame*37)&255,ry=(phase*73)&255,ex=(phase*17)&255,ey=(frame*19)&255;
  if(p==1||p==3)wr(c,raw,255);if(p==2||p==3)wr(c,raw+(p==3?4:0),254);
  wr(c,start,frame%254);wr(c,start+1,rx);wr(c,start+2,ry);wr(c,start+3,0x53);
  if(q==1||q==3)wr(c,start+4,255);if(q==2||q==3)wr(c,start+4+(q==3?4:0),254);
  wr(c,target,phase%254);wr(c,target+1,ex);wr(c,target+2,ey);wr(c,target+3,0x5A);
  wr(c,0xFFAD,5);wr(c,0xFFAE,0);wr(c,0xC115,5);wr(c,0xC116,0);wr(c,0xC21C,0x63);wr(c,0xC21D,0);wr(c,0xC5CF,phase);wr(c,0xC5CE,frame);wr(c,0xC5CD,0x37);wr(c,0xC5CB,0x39);wr(c,0xC5CC,0x3C);wr(c,0xC5EA,0x5A);wr(c,0xC5EF,0x37);wr(c,0xC5F0,0x39);wr(c,0xC5F3,0x3C);wr(c,0xC5F4,0x5A);wr(c,0xC5F5,0xA5);wr(c,0xC5F7,0x5A);
  cpu->af=0x5A00|(phase&15)<<4;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0xD000;call(c,0x5117);
  unsigned x=(rx-0xC9)&255,y=(ry-0xD0)&255,tx=(ex-0xC9)&255,ty=(ey-0xD0)&255,dx=x>tx?x-tx:tx-x,dy=y>ty?y-ty:ty-y,hi=y>ty?y:ty,lo=y<ty?y:ty,f=0x40|(dy?0:0x80)|((hi&15)<(lo&15)?0x20:0);
  require(cpu->af==(dy<<8|f)&&cpu->bc==(lo<<8|0x37)&&cpu->de==0xD201&&cpu->hl==target+3&&rd(c,0xC5EB)==x&&rd(c,0xC5EC)==y&&rd(c,0xC5ED)==tx&&rd(c,0xC5EE)==ty&&rd(c,0xC5F1)==dx&&rd(c,0xC5F2)==dy&&rd(c,0xC5F6)==frame%254,"A12 secondary reader all phase frame bytes two sequential marker skips exact coordinates distances registers",phase*256+frame);
  require(rd(c,0xC5CF)==phase&&rd(c,0xC5CE)==frame&&rd(c,0xC5CD)==0x37&&rd(c,0xC5CB)==0x39&&rd(c,0xC5CC)==0x3C&&rd(c,0xC5EA)==0x5A&&rd(c,0xC5EF)==0x37&&rd(c,0xC5F0)==0x39&&rd(c,0xC5F3)==0x3C&&rd(c,0xC5F4)==0x5A&&rd(c,0xC5F5)==0xA5&&rd(c,0xC5F7)==0x5A&&rd(c,0xFF9D)==5&&rd(c,0xFF9E)==0&&rd(c,0xFFAD)==0x63&&rd(c,0xFFAE)==0&&rd(c,0xC115)==5&&rd(c,0xC116)==0,"A12 secondary reader retains count threshold counter steps guards and mapping mirror distinction",phase*256+frame);
 }
 }
 { /* Tick prefixes stop at the original movement/reader calls, preserving actual stack. */
 struct GB *g=c->board;prepareA12EffectMapping(c,0x63);
 for(unsigned family=0;family<2;family++)for(unsigned i=0;i<256;i++)for(unsigned j=0;j<256;j++){
  unsigned counter=family?7:i,threshold=family?7:j,frame=family?i:(i*37+j)&255,count=family?j:(j&1)?(frame+1)&255:(frame+2)&255,next=(frame+1)&255;bool below=counter<threshold,wrap=next==count;unsigned target=below?0x526A:0x5117;
  wr(c,0xC5CC,counter);wr(c,0xC5CB,threshold);wr(c,0xC5CE,frame);wr(c,0xC5CD,count);wr(c,0xC5CF,0x37);wr(c,0xC5F6,0x39);wr(c,0xC5CA,0x3C);
  wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|((i^j)&15)<<4;cpu->bc=0xBE37;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x50DF;unsigned steps=0;while(cpu->pc!=target&&steps++<80)c->step(c);
  unsigned diff=(counter-threshold)&255,f=below?0x40|(diff?0:0x80)|((counter&15)<(threshold&15)?0x20:0)|(counter<threshold?0x10:0):wrap?0x80:0x40|(next==count?0x80:0)|((next&15)<(count&15)?0x20:0)|(next<count?0x10:0),sp=below?0xCFFE:wrap?0xCFFA:0xCFFC;
  require(cpu->pc==target&&cpu->sp==sp&&cpu->af==((below?diff:wrap?0:next)<<8|f)&&cpu->bc==((below?threshold:count)<<8|0x37)&&cpu->de==0x1234&&cpu->hl==(below?0x5678:0x6EE0)&&rd(c,0xC5CE)==(below?frame:wrap?0:next)&&rd(c,0xC5CC)==counter&&rd(c,0xC5CB)==threshold&&rd(c,0xC5CD)==count&&rd(c,0xC5CF)==0x37&&rd(c,0xC5F6)==0x39&&rd(c,0xC5CA)==0x3C,"A12 secondary tick threshold frame count wrap original movement or reader boundary",family*65536+i*256+j);
  if(!below)require((rd(c,sp)|(rd(c,sp+1)<<8))==(wrap?0x5101:0x510F)&&(!wrap||(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==(frame<<8|0x40|(frame?0:0x80)|((frame&15)==15?0x20:0))),"A12 secondary tick actual call and saved AF before reader",family*65536+i*256+j);
 }
 }
 { /* Reset prefixes stop at the real reader; explicit suffixes omit reader execution. */
 struct GB *g=c->board;prepareA12EffectMapping(c,0x61);
 for(unsigned frame=0;frame<256;frame++)for(unsigned flags=0;flags<16;flags++){
  wr(c,0xC5CE,frame);wr(c,0xC5CC,0x37);wr(c,0xC5CF,0x39);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFE;wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x50D8;unsigned steps=0;while(cpu->pc!=0x5117&&steps++<20)c->step(c);
  require(cpu->pc==0x5117&&cpu->sp==0xCFFC&&(rd(c,0xCFFC)|(rd(c,0xCFFD)<<8))==0x50DE&&cpu->af==(0x5A00|flags<<4)&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0x6EE0&&rd(c,0xC5CE)==frame&&rd(c,0xC5CC)==0x37&&rd(c,0xC5CF)==0x39,"A12 secondary load prefix original reader call stack registers fields",frame*16+flags);
  wr(c,0xC5CE,frame);cpu->af=0x5A00|flags<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;call(c,0x510F);unsigned next=(frame-1)&255,f=0x40|(next?0:0x80)|((frame&15)==0?0x20:0)|(flags&1?0x10:0);
  require(cpu->af==(next<<8|f)&&rd(c,0xC5CE)==next&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0x5678,"A12 secondary ordinary suffix decrements reader frame byte with flags",frame*16+flags);
  wr(c,0xC5CE,0x37);wr(c,0xFFFF,0);wr(c,0xFF0F,0);g->memory.ime=false;cpu->irqPending=false;cpu->halted=false;cpu->af=0x5A00;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;cpu->sp=0xCFFC;wr(c,0xCFFC,flags<<4);wr(c,0xCFFD,frame);wr(c,0xCFFE,0);wr(c,0xCFFF,0xC1);cpu->pc=0x5101;steps=0;while(cpu->pc!=0xC100&&steps++<20)c->step(c);
  require(cpu->pc==0xC100&&cpu->sp==0xD000&&cpu->af==(frame<<8|flags<<4)&&rd(c,0xC5CE)==frame&&cpu->bc==0xBEEF&&cpu->de==0x1234&&cpu->hl==0x5678,"A12 secondary wrap suffix pops original saved AF and restores frame synthetic stack",frame*16+flags);
 }
 }
 { /* Complete variant0 through both actual movement paths and zero availability. */
 for(unsigned counter=0;counter<4;counter++)for(unsigned accel=0;accel<256;accel++){
  unsigned x=(accel*37)&255,y=(accel*19)&255,tx=(x+23)&255,ty=(y-17)&255,dx=x>tx?x-tx:tx-x,dy=y>ty?y-ty:ty-y;struct A12StepModel sx=a12StepModel(dx,7,counter),sy=a12StepModel(dy,7,counter);unsigned nx=(x<tx?x+sx.q:x-sx.q)&255,ny=(y<ty?y+sy.q:y-sy.q)&255,next=(counter+(accel?4:1))&255,f=accel?((next?0:0x80)|(((next-1)&15)==15?0x20:0)):0xA0;
  prepareA12EffectMapping(c,0x63);wr(c,0xC5D7,x);wr(c,0xC5D8,y);wr(c,0xC5D9,tx);wr(c,0xC5DA,ty);wr(c,0xC5DD,dx);wr(c,0xC5DE,dy);wr(c,0xC5EB,x);wr(c,0xC5EC,y);wr(c,0xC5ED,tx);wr(c,0xC5EE,ty);wr(c,0xC5F1,dx);wr(c,0xC5F2,dy);wr(c,0xC5CB,7);wr(c,0xC5CC,counter);wr(c,0xC73A,accel);wr(c,0xC1C7,0);wr(c,0xC5F5,0x37);wr(c,0xC5CE,0x39);wr(c,0xC5CF,0x3C);cpu->af=0x5A00|(accel&15)<<4;cpu->bc=0xBEEF;cpu->de=0x1234;cpu->hl=0x5678;callWithLimit(c,0x4A36,400000);
  require(cpu->af==(accel<<8|f)&&cpu->bc==7&&cpu->de==0x1234&&cpu->hl==0xC5CC&&rd(c,0xC5D7)==nx&&rd(c,0xC5D8)==ny&&rd(c,0xC5D5)==nx&&rd(c,0xC5D6)==ny&&rd(c,0xC5EB)==nx&&rd(c,0xC5EC)==ny&&rd(c,0xC5E9)==nx&&rd(c,0xC5EA)==ny&&rd(c,0xC5CC)==next&&rd(c,0xC5CB)==7&&rd(c,0xC73A)==accel&&rd(c,0xC5F5)==0&&rd(c,0xC1C7)==0&&rd(c,0xC5CE)==0x39&&rd(c,0xC5CF)==0x3C&&rd(c,0xC21C)==0x61&&rd(c,0xC21D)==0&&rd(c,0xFFAD)==0x61&&rd(c,0xC115)==5&&rd(c,0xFF9D)==0x61,"A12 variant0 full secondary and primary movement copies two zero-availability emitters counter",counter*256+accel);
 }
 }
 { /* Original nine secondary resources; inconsistent count is explicitly adversarial. */
 const unsigned pointers[]={0x6EF2,0x6F57,0x7080,0x70BD,0x70FE,0x713B,0x716C,0x71A1,0x71D2},counts[]={24,73,14,15,14,11,12,11,11};const uint8_t *rom=((struct GB*)c->board)->memory.rom;
 memcpy(originalSecondaryResources,rom+0x61*8192+0xEE0,sizeof(originalSecondaryResources));
 unsigned sample=0;
 for(unsigned phase=0;phase<9;phase++){
  unsigned table=0x61*8192+0xEE0+2*phase,ptr=rom[table]|rom[table+1]<<8,next=phase<8?pointers[phase+1]:0x7203;
  require(ptr==pointers[phase]&&rom[0x61*8192+ptr-0x6000]==counts[phase]&&ptr+1+4*(counts[phase]+1)==next,"Original secondary nine pointer count and exact object boundary contracts",phase);
  for(unsigned frame=0;frame<counts[phase];frame++){
   for(unsigned flags=0;flags<16;flags++){probeOriginalA12Secondary(c,phase,frame,counts[phase],flags<<4,false,sample++);probeOriginalA12Secondary(c,phase,frame,counts[phase],flags<<4,true,sample++);}
   for(unsigned count=0;count<256;count++)probeOriginalA12Secondary(c,phase,frame,count,((frame^count)&15)<<4,true,sample++);
  }
 }
 printf("Original secondary resources: %u complete load/tick calls; %u modeled reads beyond measured object (adversarial counts), within ROM window\n",sample,originalSecondaryCrossings);
 }
 { /* Paired original resources; primary current FF/FE effects remain separate. */
 const unsigned pointers[]={0x6BCF,0x6C34,0x6D5D,0x6D9A,0x6DDB,0x6E18,0x6E49,0x6E7E,0x6EAF},counts[]={24,73,14,15,14,11,12,11,11};const uint8_t *rom=((struct GB*)c->board)->memory.rom;
 memcpy(originalPairedResources,rom+0x61*8192+0xBBD,sizeof(originalPairedResources));unsigned sample=0,ordinary=0,effects=0;
 for(unsigned phase=0;phase<9;phase++){
  unsigned table=0x61*8192+0xBBD+2*phase,p=rom[table]|rom[table+1]<<8,next=phase<8?pointers[phase+1]:0x6EE0;
  require(p==pointers[phase]&&rom[0x61*8192+p-0x6000]==counts[phase]&&p+1+4*(counts[phase]+1)==next&&rom[0x61*8192+(rom[0x61*8192+0xEE0+2*phase]|rom[0x61*8192+0xEE1+2*phase]<<8)-0x6000]==counts[phase],"Original primary table exact pointers counts extents paired secondary counts measured",phase);
  for(unsigned counter=0;counter<256;counter++)for(unsigned flags=0;flags<16;flags++)probeOriginalA12Pair(c,phase,0,counter,flags<<4,true,sample++);
  for(unsigned frame=0;frame<counts[phase];frame++){
   if(rom[0x61*8192+p+1+4*frame-0x6000]>=254){effects++;continue;}ordinary++;
   for(unsigned counter=0;counter<256;counter++)probeOriginalA12Pair(c,phase,frame,counter,((counter^frame)&15)<<4,false,sample++);
  }
 }
 printf("Original paired resources: %u reset/read-to-secondary chains; %u ordinary frames; %u current effect frames reserved\n",sample,ordinary,effects);
 }
 { /* All thirteen original current effects, full readers and secondary pairing. */
 const unsigned phases[]={0,0,0,0,0,0,3,4,5,5,6,7,8},frames[]={1,2,5,12,14,15,3,5,1,4,3,5,5},tiles[]={0x6800,0x6837,0x6A0F},sizes[]={55,55,67};const uint8_t *rom=((struct GB*)c->board)->memory.rom;
 memcpy(originalPairedResources,rom+0x61*8192+0xBBD,sizeof(originalPairedResources));
 for(unsigned i=0;i<3;i++){const uint8_t *h=rom+0x61*8192+tiles[i]-0x6000;memcpy(originalEffectTiles[i],h,sizes[i]);require(h[4]==2&&7+2*h[2]*h[3]*h[4]==sizes[i],"Original three FF tile resources measured two-frame extents",i);}
 for(unsigned effect=0;effect<13;effect++)for(unsigned counter=0;counter<256;counter++)for(unsigned plane=0;plane<2;plane++)for(unsigned lcd=0;lcd<2;lcd++)probeOriginalA12Effects(c,phases[effect],frames[effect],counter,(counter&15)<<4,plane,lcd,effect*1024+counter*4+plane*2+lcd);
 }
 printf("PASS SYNTHETIC storage probes: %u assertions; version=%s commit=%s\n",
        checks,projectVersion,gitCommit);
 c->unloadROM(c);mCoreConfigDeinit(&c->config);c->deinit(c);return 0;
}
