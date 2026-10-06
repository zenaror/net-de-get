/* Pass-through CPU store observer: records mapper writes and Index80 scratch
 * bookkeeping, then delegates every store unchanged. No guest injection.
 * Compile with all feature defines of the linked library (internal ABI). */
#include <mgba/flags.h>
#include <mgba/core/core.h>
#include <mgba/core/config.h>
#include <mgba/core/directories.h>
#include <mgba/internal/gb/gb.h>
#include <mgba/internal/sm83/sm83.h>
#include <mgba-util/vfs.h>
#include <mgba-util/image.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
static void snapshot(struct mCore*c,const char*dir,int stage) {
 unsigned w,h;c->currentVideoSize(c,&w,&h);const void*p;size_t stride;c->getPixels(c,&p,&stride);
 char path[512];snprintf(path,sizeof(path),"%s/stage-%02d.ppm",dir,stage);FILE*f=fopen(path,"wb");
 if(!f)return;fprintf(f,"P6\n%u %u\n255\n",w,h);const mColor*pix=p;
 for(unsigned y=0;y<h;y++)for(unsigned x=0;x<w;x++){mColor v=pix[y*stride+x];fputc(M_R8(v),f);fputc(M_G8(v),f);fputc(M_B8(v),f);}fclose(f);
 struct GB*g=c->board;printf("stage=%d frame=%u pc=%04X A=%u B=%u fixtureFrames=%u held=%02X pressed=%02X counters=",stage,c->frameCounter(c),g->cpu->pc,g->memory.currentBank,g->memory.currentBank1,c->busRead8(c,0xD800),c->busRead8(c,0xD802),c->busRead8(c,0xD801));for(int i=0;i<8;i++)printf("%02X",c->busRead8(c,0xD803+i));printf(" exitCode=%02X IE=%02X IF=%02X IME=%d FF8A=%02X joy=%02X STAT=%02X LCDC=%02X LY=%02X SP=%04X halted=%d pending=%d FF8E=%02X FF8F=%02X\n",c->busRead8(c,0xC671),c->busRead8(c,0xFFFF),c->busRead8(c,0xFF0F),g->memory.ime,c->busRead8(c,0xFF8A),c->busRead8(c,0xFF96),c->busRead8(c,0xFF41),c->busRead8(c,0xFF40),c->busRead8(c,0xFF44),g->cpu->sp,g->cpu->halted,g->cpu->irqPending,c->busRead8(c,0xFF8E),c->busRead8(c,0xFF8F));
}

static struct mCore* watched;
static void (*originalStore)(struct SM83Core*,uint16_t,int8_t);
static unsigned lastA,lastB;
static void mapperStore(struct SM83Core*cpu,uint16_t address,int8_t value){
 struct GB*g=watched->board;unsigned v=(unsigned char)value;
 unsigned target=address>>10;
 if(target==8||target==9)lastA=v;
 if(target==12||target==13)lastB=v;
 if((address==0xC5C5&&v==0x80) || (address>=0x2000&&address<0x4000 && (v==0x80||((target==14||target==15)&&lastB==0x80)))){
  printf("MAP frame=%u pc=%04X addr=%04X value=%02X A=%d B=%d reqA=%02X reqB=%02X flashAB=%d%d en=%d oldC5C5=%02X SP=%04X stack=",watched->frameCounter(watched),cpu->pc,address,v,g->memory.currentBank,g->memory.currentBank1,lastA,lastB,g->memory.mbcState.mbc6.flashBank0,g->memory.mbcState.mbc6.flashBank1,g->memory.mbcState.mbc6.flashEnable,watched->busRead8(watched,0xC5C5),cpu->sp);
  for(int i=0;i<10;i++)printf("%02X",watched->busRead8(watched,cpu->sp+i));printf("\n");fflush(stdout);
 }
 originalStore(cpu,address,value);
}

int main(int argc,char**argv){if(argc<4)return 2;struct mCore*c=mCoreFind(argv[1]);if(!c||!c->init(c))return 3;mCoreInitConfig(c,"natural-pad-test");if(!mCoreLoadFile(c,argv[1]))return 4;c->dirs.save=VDirOpen(argv[2]);strcpy(c->dirs.baseName,"padtest");if(!mCoreAutoloadSave(c))return 5;mColor*video=calloc(256*256,sizeof(mColor));c->setVideoBuffer(c,video,256);c->reset(c); watched=c; originalStore=((struct GB*)c->board)->cpu->memory.store8; ((struct GB*)c->board)->cpu->memory.store8=mapperStore;
 for(int i=3;i<argc;i++){unsigned key,frames;if(sscanf(argv[i],"%u:%u",&key,&frames)!=2)return 6;c->setKeys(c,key);for(unsigned j=0;j<frames;j++)c->runFrame(c);snapshot(c,argv[2],i-3);}
 c->setKeys(c,0);c->unloadROM(c);mCoreConfigDeinit(&c->config);c->deinit(c);free(video);return 0;}
