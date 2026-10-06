#include <mgba/internal/gb/gb.h>
#include <mgba/internal/sm83/sm83.h>
#include <mgba/core/core.h>
#include <mgba/core/config.h>
#include <mgba/core/directories.h>
#include <mgba-util/vfs.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#define STORAGE 0x100101
static void wr(struct mCore*c,unsigned a,unsigned v){
    c->busWrite8(c,a,v);
}
static unsigned rd(struct mCore*c,unsigned a){
    return c->busRead8(c,a);
}
static unsigned char* file(const char*p,size_t*n){
    FILE*f=fopen(p,"rb");
    if(!f)return NULL;
    fseek(f,0,SEEK_END);
    *n=ftell(f);
    rewind(f);
    unsigned char*b=malloc(*n);
    if(fread(b,1,*n,f)!=*n)exit(2);
    fclose(f);
    return b;
}
/* Isolated original-ROM checksum validator; entry is synthetic. */
static int validate(struct mCore*c){
    struct GB*g=c->board;
    wr(c,0x3000,1);
    wr(c,0x3800,8);
    wr(c,0x0C00,1);
    wr(c,0xFFAD,1);
    wr(c,0xFFAE,8);
    wr(c,0xC115,1);
    wr(c,0xC116,8);
    wr(c,0xFFFF,0);
    wr(c,0xFF0F,0);
    g->memory.ime=false;
    g->cpu->irqPending=false;
    g->cpu->halted=false;
    g->cpu->sp=0xCFFE;
    wr(c,0xCFFE,0);
    wr(c,0xCFFF,0xC1);
    g->cpu->pc=0x38B0;
    unsigned steps=0;
    while(g->cpu->pc!=0xC100&&steps++<1000000)c->step(c);
    return g->cpu->pc==0xC100 ? !!(g->cpu->af&0x80) : -1;
}
int main(int ac,char**av){
    if(ac!=5)return 2;
    size_t wn,pn;
    unsigned char*w=file(av[3],&wn),*p=file(av[4],&pn);
    if(!w||!p||!wn||!pn||wn>0x5000||pn>0x4000)return 2;
    struct mCore*c=mCoreFind(av[1]);
    if(!c||!c->init(c))return 3;
    mCoreInitConfig(c,"producer-trace");
    if(!mCoreLoadFile(c,av[1]))return 4;
    c->dirs.save=VDirOpen(av[2]);
    strcpy(c->dirs.baseName,"producer");
    if(!mCoreAutoloadSave(c))return 5;
    c->reset(c);
    struct GB*g=c->board;
    for(unsigned i=0;i<300;i++)c->runFrame(c);
    /* Synthetic response staged in disposable SRAM; the ROM owns output production. */
    memcpy(g->memory.sram+0x2000,w,wn);
    wr(c,0xFF70,4);
    for(unsigned i=0;i<0x1000;i++)wr(c,0xD000+i,0);
    wr(c,0xFF70,1);
    wr(c,0xDF12,1);
    wr(c,0xDF17,0);
    wr(c,0xDF18,0x40);
    wr(c,0xDF0F,1);
    wr(c,0xCEE9,0);
    wr(c,0x2000,0x10);
    wr(c,0x2800,0);
    wr(c,0x3000,6);
    wr(c,0x3800,0);
    wr(c,0xFFAB,0x10);
    wr(c,0xFFAC,0);
    wr(c,0xFFAD,6);
    wr(c,0xFFAE,0);
    wr(c,0xC113,0x10);
    wr(c,0xC114,0);
    wr(c,0xC115,6);
    wr(c,0xC116,0);
    wr(c,0xFF8E,0);
    wr(c,0xFF8F,0);
    wr(c,0xFF8A,0);
    wr(c,0xFF0F,0);
    wr(c,0xFFFF,1);
    g->memory.ime=true;
    g->cpu->irqPending=false;
    g->cpu->halted=false;
    g->cpu->sp=0xCFFE;
    wr(c,0xCFFE,0);
    wr(c,0xCFFF,0xC1);
    g->cpu->a=2;
    g->cpu->hl=0xB000;
    g->cpu->de=0x61C5;
    g->cpu->pc=0x4000;
    printf("entry=%04X selectorA=%u selectorB=%u code=%02X%02X%02X wrapper=%zu expected=%zu\n",g->cpu->pc,g->memory.currentBank,g->memory.currentBank1,rd(c,0x4000),rd(c,0x4001),rd(c,0x4002),wn,pn);
    unsigned long steps=0;
    unsigned ops=0,callbacks=0,vblanks=0,produces=0;
    unsigned first=0,last=0;
    int busy=0;
    while(g->cpu->pc!=0xC100&&steps<20000000){
        unsigned pc=g->cpu->pc;
        if(pc>=0x8000){
            printf("unexpected_pc=%04X\n",pc);
            break;
        }
        if(pc==0x61C5)callbacks++;
        if(pc==0x0607)vblanks++;
        if(pc==0x4BC1&&g->memory.currentBank==0x10)produces++;
        c->step(c);
        steps++;
        int now=g->memory.mbcState.mbc6.flashOperationBusy;
        if(now&&!busy){
            unsigned t=g->memory.mbcState.mbc6.flashOperationTarget;
            if(!ops)first=t;
            last=t;
            ops++;
        }
        busy=now;
    }
    unsigned char*f=g->memory.sram+g->memory.sramSize-STORAGE;
    size_t padded=(pn+0xFFF)&~0xFFF;
    unsigned bad=0;
    for(size_t i=0;i<pn;i++){
        if(f[0x2000+i]!=p[i])bad++;
    }
    unsigned padding=0;
    for(size_t i=pn;i<padded;i++)padding+=f[0x2000+i]!=0;
    printf("result pc=%04X A=%02X steps=%lu produces=%u callbacks=%u vblanks=%u ops=%u targets=%06X-%06X busy=%d mismatches=%u output=%zu padded=%zu nonzero_padding=%u DF18=%02X\n",g->cpu->pc,g->cpu->a,steps,produces,callbacks,vblanks,ops,first,last,g->memory.mbcState.mbc6.flashOperationBusy,bad,pn,padded,padding,rd(c,0xDF18));
    int pass=g->cpu->pc==0xC100&&g->cpu->a==0&&!bad&&!g->memory.mbcState.mbc6.flashOperationBusy&&callbacks==padded/0x1000&&ops==padded/0x80&&first==0x2000&&last==0x2000+padded-0x80;
    c->unloadROM(c);
    mCoreConfigDeinit(&c->config);
    c->deinit(c);
    /* Reload persisted flash through a fresh core, rather than comparing RAM only. */
    c=mCoreFind(av[1]);
    if(!c||!c->init(c))return 11;
    mCoreInitConfig(c,"producer-reopen");
    if(!mCoreLoadFile(c,av[1]))return 12;
    c->dirs.save=VDirOpen(av[2]);
    strcpy(c->dirs.baseName,"producer");
    if(!mCoreAutoloadSave(c))return 13;
    c->reset(c);
    g=c->board;
    f=g->memory.sram+g->memory.sramSize-STORAGE;
    bad=0;
    for(size_t i=0;i<pn;i++)bad+=f[0x2000+i]!=p[i];
    printf("reopen mismatches=%u busy=%d\n",bad,g->memory.mbcState.mbc6.flashOperationBusy);
    pass=pass&&!bad&&!g->memory.mbcState.mbc6.flashOperationBusy;
    if(pn==8192){
        int good=validate(c);
        f[0x2000+0x100]^=1;
        int corrupt=validate(c);
        f[0x2000+0x100]^=1;
        printf("checksum original_Z=%d corrupt_Z=%d\n",good,corrupt);
        pass=pass&&good==1&&corrupt==0;
    }
    c->unloadROM(c);
    mCoreConfigDeinit(&c->config);
    c->deinit(c);
    free(w);
    free(p);
    return pass?0:10;
}
