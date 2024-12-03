---@diagnostic disable
local a=dofile"/rom/modules/main/cc/expect.lua"setmetatable(a,{__call=function(b,...)return a.expect(...)end})local c={}local d="ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"local e={[1]=0,[2]=keys.one,[3]=keys.two,[4]=keys.three,[5]=keys.four,[6]=keys.five,[7]=keys.six,[8]=keys.seven,[9]=keys.eight,[10]=keys.nine,[11]=keys.zero,[12]=keys.minus,[13]=keys.equals,[14]=keys.backspace,[15]=keys.tab,[16]=keys.q,[17]=keys.w,[18]=keys.e,[19]=keys.r,[20]=keys.t,[21]=keys.y,[22]=keys.u,[23]=keys.i,[24]=keys.o,[25]=keys.p,[26]=keys.leftBracket,[27]=keys.rightBracket,[28]=keys.enter,[29]=keys.leftCtrl,[30]=keys.a,[31]=keys.s,[32]=keys.d,[33]=keys.f,[34]=keys.g,[35]=keys.h,[36]=keys.j,[37]=keys.k,[38]=keys.l,[39]=keys.semiColon,[40]=keys.apostrophe,[41]=keys.grave,[42]=keys.leftShift,[43]=keys.backslash,[44]=keys.z,[45]=keys.x,[46]=keys.c,[47]=keys.v,[48]=keys.b,[49]=keys.n,[50]=keys.m,[51]=keys.comma,[52]=keys.period,[53]=keys.slash,[54]=keys.rightShift,[55]=keys.multiply,[56]=keys.leftAlt,[57]=keys.space,[58]=keys.capsLock,[59]=keys.f1,[60]=keys.f2,[61]=keys.f3,[62]=keys.f4,[63]=keys.f5,[64]=keys.f6,[65]=keys.f7,[66]=keys.f8,[67]=keys.f9,[68]=keys.f10,[69]=keys.numLock,[70]=keys.scrollLock,[71]=keys.numPad7,[72]=keys.numPad8,[73]=keys.numPad9,[74]=keys.numPadSubtract,[75]=keys.numPad4,[76]=keys.numPad5,[77]=keys.numPad6,[78]=keys.numPadAdd,[79]=keys.numPad1,[80]=keys.numPad2,[81]=keys.numPad3,[82]=keys.numPad0,[83]=keys.numPadDecimal,[87]=keys.f11,[88]=keys.f12,[100]=keys.f13,[101]=keys.f14,[102]=keys.f15,[111]=keys.kana,[121]=keys.convert,[123]=keys.noconvert,[125]=keys.yen,[141]=keys.numPadEquals,[144]=keys.cimcumflex,[145]=keys.at,[146]=keys.colon,[147]=keys.underscore,[148]=keys.kanji,[149]=keys.stop,[150]=keys.ax,[156]=keys.numPadEnter,[157]=keys.rightCtrl,[179]=keys.numPadComma,[181]=keys.numPadDivide,[184]=keys.rightAlt,[197]=keys.pause,[199]=keys.home,[200]=keys.up,[201]=keys.pageUp,[203]=keys.left,[205]=keys.right,[207]=keys["end"],[208]=keys.down,[209]=keys.pageDown,[210]=keys.insert,[211]=keys.delete}local f={[0]=1,[keys.one]=2,[keys.two]=3,[keys.three]=4,[keys.four]=5,[keys.five]=6,[keys.six]=7,[keys.seven]=8,[keys.eight]=9,[keys.nine]=10,[keys.zero]=11,[keys.minus]=12,[keys.equals]=13,[keys.backspace]=14,[keys.tab]=15,[keys.q]=16,[keys.w]=17,[keys.e]=18,[keys.r]=19,[keys.t]=20,[keys.y]=21,[keys.u]=22,[keys.i]=23,[keys.o]=24,[keys.p]=25,[keys.leftBracket]=26,[keys.rightBracket]=27,[keys.enter]=28,[keys.leftCtrl]=29,[keys.a]=30,[keys.s]=31,[keys.d]=32,[keys.f]=33,[keys.g]=34,[keys.h]=35,[keys.j]=36,[keys.k]=37,[keys.l]=38,[keys.semicolon or keys.semiColon]=39,[keys.apostrophe]=40,[keys.grave]=41,[keys.leftShift]=42,[keys.backslash]=43,[keys.z]=44,[keys.x]=45,[keys.c]=46,[keys.v]=47,[keys.b]=48,[keys.n]=49,[keys.m]=50,[keys.comma]=51,[keys.period]=52,[keys.slash]=53,[keys.rightShift]=54,[keys.leftAlt]=56,[keys.space]=57,[keys.capsLock]=58,[keys.f1]=59,[keys.f2]=60,[keys.f3]=61,[keys.f4]=62,[keys.f5]=63,[keys.f6]=64,[keys.f7]=65,[keys.f8]=66,[keys.f9]=67,[keys.f10]=68,[keys.numLock]=69,[keys.scollLock or keys.scrollLock]=70,[keys.numPad7]=71,[keys.numPad8]=72,[keys.numPad9]=73,[keys.numPadSubtract]=74,[keys.numPad4]=75,[keys.numPad5]=76,[keys.numPad6]=77,[keys.numPadAdd]=78,[keys.numPad1]=79,[keys.numPad2]=80,[keys.numPad3]=81,[keys.numPad0]=82,[keys.numPadDecimal]=83,[keys.f11]=87,[keys.f12]=88,[keys.f13]=100,[keys.f14]=101,[keys.f15]=102,[keys.numPadEquals or keys.numPadEqual]=141,[keys.numPadEnter]=156,[keys.rightCtrl]=157,[keys.rightAlt]=184,[keys.pause]=197,[keys.home]=199,[keys.up]=200,[keys.pageUp]=201,[keys.left]=203,[keys.right]=205,[keys["end"]]=207,[keys.down]=208,[keys.pageDown]=209,[keys.insert]=210,[keys.delete]=211}local function g(h)local i;if _CC_VERSION then i=h<=_CC_VERSION elseif not _HOST then i=h<=os.version():gsub("CraftOS ","")elseif _HOST:match("ComputerCraft 1%.1%d+")~=h:match("1%.1%d+")then h=h:gsub("(1%.)([02-9])","%10%2")local j=_HOST:gsub("(ComputerCraft 1%.)([02-9])","%10%2")i=h<=j:match("ComputerCraft ([0-9%.]+)")else i=h<=_HOST:match("ComputerCraft ([0-9%.]+)")end;assert(i,"This program requires ComputerCraft "..h.." or later.")end;local function k(l)local m=""for n in l:gmatch"..."do local o=n:byte(1)*65536+n:byte(2)*256+n:byte(3)local p,q,r,s=bit32.extract(o,18,6),bit32.extract(o,12,6),bit32.extract(o,6,6),bit32.extract(o,0,6)m=m..d:sub(p+1,p+1)..d:sub(q+1,q+1)..d:sub(r+1,r+1)..d:sub(s+1,s+1)end;if#l%3==1 then local o=l:byte(-1)local p,q=bit32.rshift(o,2),bit32.lshift(bit32.band(o,3),4)m=m..d:sub(p+1,p+1)..d:sub(q+1,q+1).."=="elseif#l%3==2 then local o=l:byte(-2)*256+l:byte(-1)local p,q,r,s=bit32.extract(o,10,6),bit32.extract(o,4,6),bit32.lshift(bit32.extract(o,0,4),2)m=m..d:sub(p+1,p+1)..d:sub(q+1,q+1)..d:sub(r+1,r+1).."="end;return m end;local function t(l)local m=""for n in l:gmatch"...."do if n:sub(3,4)=='=='then m=m..string.char(bit32.bor(bit32.lshift(d:find(n:sub(1,1))-1,2),bit32.rshift(d:find(n:sub(2,2))-1,4)))elseif n:sub(4,4)=='='then local o=(d:find(n:sub(1,1))-1)*4096+(d:find(n:sub(2,2))-1)*64+d:find(n:sub(3,3))-1;m=m..string.char(bit32.extract(o,10,8))..string.char(bit32.extract(o,2,8))else local o=(d:find(n:sub(1,1))-1)*262144+(d:find(n:sub(2,2))-1)*4096+(d:find(n:sub(3,3))-1)*64+d:find(n:sub(4,4))-1;m=m..string.char(bit32.extract(o,16,8))..string.char(bit32.extract(o,8,8))..string.char(bit32.extract(o,0,8))end end;return m end;local u;local function v(l)if not u then u={}for w=0,0xFF do local x=w;for y=1,8 do if bit32.band(x,1)==1 then x=bit32.rshift(x,1)x=bit32.bxor(x,0xEDB88320)else x=bit32.rshift(x,1)end end;u[w]=x end end;local z=0xFFFFFFFF;for A=1,#l do z=bit32.bxor(bit32.rshift(z,8),u[bit32.bxor(bit32.band(z,0xFF),l:byte(A))])end;return bit32.bxor(z,0xFFFFFFFF)end;local function B(C,D)local E=C:byte(D)D=D+1;local F;if E==0 then F="<j"elseif E==1 then F="<n"elseif E==2 then F="<B"elseif E==3 then F="<z"elseif E==4 then local G,keys={},{}local H=C:byte(D)D=D+1;for w=1,H do keys[w],D=B(C,D)end;for w=1,H do G[keys[w]],D=B(C,D)end;return G,D else return nil,D end;local s;s,D=string.unpack(F,C,D)if E==2 then s=s~=0 end;return s,D end;local function I(J)if type(J)=="number"then if J%1==0 and J>=-0x80000000 and J<0x80000000 then return string.pack("<Bj",0,J)else return string.pack("<Bn",1,J)end elseif type(J)=="boolean"then return string.pack("<BB",2,J and 1 or 0)elseif type(J)=="string"then return string.pack("<Bz",3,J)elseif type(J)=="nil"then return"\5"elseif type(J)=="table"then local keys,K={},{}local w=1;for L,M in pairs(J)do keys[w],K[w],w=L,M,w+1 end;local n=string.pack("<BB",4,w-1)for y=1,w-1 do n=n..I(keys[y])end;for y=1,w-1 do n=n..I(K[y])end;return n else error("Cannot encode type "..type(J))end end;local N={[0]="mouse_click","mouse_up","mouse_scroll","mouse_drag"}local O={[0]=fs.exists,fs.isDir,fs.isReadOnly,fs.getSize,fs.getDrive,fs.getCapacity,fs.getFreeSpace,fs.list,fs.attributes,fs.find,fs.makeDir,fs.delete,fs.copy,fs.move,function()end,function()end}if not fs.attributes then O[8]=function(P)a(1,P,"string")if not fs.exists(P)then return nil end;return{size=fs.getSize(P),isDir=fs.isDir(P),isReadOnly=fs.isReadOnly(P),created=0,modified=0}end end;local Q={[0]="r","w","r","a","rb","wb","rb","ab"}local R={key=true,key_up=true,char=true,mouse_click=true,mouse_up=true,mouse_drag=true,mouse_scroll=true,mouse_move=true,term_resize=true,paste=true}if not string.pack then g"1.91.0"end;function c.server(S,T,U,V,W,X,A,Y,Z,_)a(1,S,"table")a(2,T,"number")a(3,U,"number")a(4,V,"number","nil")a(5,W,"string","nil")a(6,X,"table","nil")a(7,A,"number","nil")a(8,Y,"number","nil")a.field(S,"send","function")a.field(S,"receive","function")a.field(S,"close","function","nil")W=W or"CraftOS Raw Terminal"A=A or 1;Y=Y or 1;local a0,a1,a2,a3,a4,a5,a6,a7,a8={},0,1,1,0xF0,true,false,false,true;local a9,aa,ab,ac,ad={},{},{},{},{}local ae=S.flags or{isVersion11=false,filesystem=false,binaryChecksum=false}S.flags=ae;for w=1,U do a9[w],aa[w]=(" "):rep(T),("\xF0"):rep(T)end;for w=1,U*9 do ab[w]=("\x0F"):rep(T*6)end;for w=0,15 do ac[w]={(X or term).getPaletteColor(2^w)}end;for w=16,255 do ac[w]={0,0,0}end;local function af(type,V,C)local ag=k(string.char(type)..string.char(V or 0)..C)local s;if#ag>65535 and ae.isVersion11 then s="!CPD"..string.format("%012X",#ag)else s="!CPC"..string.format("%04X",#ag)end;s=s..ag;if ae.binaryChecksum and V~=6 then s=s..("%08X"):format(v(string.char(type)..string.char(V or 0)..C))else s=s..("%08X"):format(v(ag))end;return s.."\n"end;function a0.write(ah)ah=tostring(ah)a(1,ah,"string")if a3<1 or a3>U then return elseif a2>T or a2+#ah<1 then a2=a2+#ah;return elseif a2<1 then ah=ah:sub(-a2+2)a2=1 end;local ai=#ah;if a2+#ah>T then ah=ah:sub(1,T-a2+1)end;a9[a3]=a9[a3]:sub(1,a2-1)..ah..a9[a3]:sub(a2+#ah)aa[a3]=aa[a3]:sub(1,a2-1)..string.char(a4):rep(#ah)..aa[a3]:sub(a2+#ah)a2=a2+ai;a8=true;a0.redraw()end;function a0.blit(ah,aj,ak)ah=tostring(ah)a(1,ah,"string")a(2,aj,"string")a(3,ak,"string")if#ah~=#aj or#aj~=#ak then error("Arguments must be the same length",2)end;if a3<1 or a3>U then return elseif a2>T or a2<1-#ah then a2=a2+#ah;a0.redraw()return elseif a2<1 then ah,aj,ak=ah:sub(-a2+2),aj:sub(-a2+2),ak:sub(-a2+2)a2=1;a0.redraw()end;local ai=#ah;if a2+#ah>T then ah,aj,ak=ah:sub(1,T-a2+1),aj:sub(1,T-a2+1),ak:sub(1,T-a2+1)end;local al=""for w=1,#ah do al=al..string.char((tonumber(ak:sub(w,w),16)or 0)*16+(tonumber(aj:sub(w,w),16)or 0))end;a9[a3]=a9[a3]:sub(1,a2-1)..ah..a9[a3]:sub(a2+#ah)aa[a3]=aa[a3]:sub(1,a2-1)..al..aa[a3]:sub(a2+#ah)a2=a2+ai;a8=true;a0.redraw()end;function a0.clear()if a1==0 then for w=1,U do a9[w],aa[w]=(" "):rep(T),string.char(a4):rep(T)end else for w=1,U*9 do ab[w]=("\x0F"):rep(T*6)end end;a8=true;a0.redraw()end;function a0.clearLine()if a3>=1 and a3<=U then a9[a3],aa[a3]=(" "):rep(T),string.char(a4):rep(T)a8=true;a0.redraw()end end;function a0.getCursorPos()return a2,a3 end;function a0.setCursorPos(am,an)a(1,am,"number")a(2,an,"number")am,an=math.floor(am),math.floor(an)if am==a2 and an==a3 then return end;a2,a3=am,an;a8=true;a0.redraw()end;function a0.getCursorBlink()return a6 end;function a0.setCursorBlink(q)a(1,q,"boolean")a6=q;if X then X.setCursorBlink(q)end;a0.redraw()end;function a0.isColor()if X then return X.isColor()end;return true end;function a0.getSize(ao)if type(ao)=="number"and ao>1 or type(ao)=="boolean"and ao==true then return T*6,U*9 else return T,U end end;function a0.scroll(ap)a(1,ap,"number")if math.abs(ap)>=T then for w=1,U do a9[w],aa[w]=(" "):rep(T),string.char(a4):rep(T)end elseif ap>0 then for w=ap+1,U do a9[w-ap],aa[w-ap]=a9[w],aa[w]end;for w=U-ap+1,U do a9[w],aa[w]=(" "):rep(T),string.char(a4):rep(T)end elseif ap<0 then for w=1,U+ap do a9[w-ap],aa[w-ap]=a9[w],aa[w]end;for w=1,-ap do a9[w],aa[w]=(" "):rep(T),string.char(a4):rep(T)end else return end;a8=true;a0.redraw()end;function a0.getTextColor()return 2^bit32.band(a4,0x0F)end;function a0.setTextColor(aq)a(1,aq,"number")a4=bit32.band(a4,0xF0)+bit32.band(math.floor(math.log(aq,2)),0x0F)end;function a0.getBackgroundColor()return 2^bit32.rshift(a4,4)end;function a0.setBackgroundColor(aq)a(1,aq,"number")a4=bit32.band(a4,0x0F)+bit32.band(math.floor(math.log(aq,2)),0x0F)*16 end;function a0.getPaletteColor(aq)a(1,aq,"number")if a1==2 then if aq<0 or aq>255 then error("bad argument #1 (value out of range)",2)end else aq=bit32.band(math.floor(math.log(aq,2)),0x0F)end;return table.unpack(ac[aq])end;function a0.setPaletteColor(aq,ar,as,q)a(1,aq,"number")a(2,ar,"number")a(3,as,"number")a(4,q,"number")if ar<0 or ar>1 then error("bad argument #2 (value out of range)",2)end;if as<0 or as>1 then error("bad argument #3 (value out of range)",2)end;if q<0 or q>1 then error("bad argument #4 (value out of range)",2)end;if a1==2 then if aq<0 or aq>255 then error("bad argument #1 (value out of range)",2)end else aq=bit32.band(math.floor(math.log(aq,2)),0x0F)end;ac[aq]={ar,as,q}a8=true;a0.redraw()end;function a0.getGraphicsMode()if a1==0 then return false else return a1 end end;function a0.setGraphicsMode(ao)a(1,ao,"boolean","number")local at=a1;if ao==false then a1=0 elseif ao==true then a1=1 elseif ao>=0 and ao<=2 then a1=math.floor(ao)else error("bad argument #1 (invalid mode)",2)end;if a1~=at then a8=true;a0.redraw()end end;function a0.getPixel(au,av)a(1,au,"number")a(2,av,"number")if au<0 or au>=T*6 or av<0 or av>=U*9 then return nil end;local r=ab[av+1]:byte(au+1,au+1)return a1==2 and r or 2^r end;function a0.setPixel(au,av,aq)a(1,au,"number")a(2,av,"number")a(3,aq,"number")if au<0 or au>=T*6 or av<0 or av>=U*9 then return nil end;if a1==2 then if aq<0 or aq>255 then error("bad argument #3 (value out of range)",2)end else aq=bit32.band(math.floor(math.log(aq,2)),0x0F)end;ab[av+1]=ab[av+1]:sub(1,au)..string.char(aq)..ab[av+1]:sub(au+2)a8=true;a0.redraw()end;function a0.drawPixels(au,av,aw,ax,ay)a(1,au,"number")a(2,av,"number")a(3,aw,"table","number")a(4,ax,"number",type(aw)~="number"and"nil"or nil)a(5,ay,"number",type(aw)~="number"and"nil"or nil)if type(aw)=="number"then if a1==2 then if aw<0 or aw>255 then error("bad argument #3 (value out of range)",2)end else aw=bit32.band(math.floor(math.log(aw,2)),0x0F)end;for an=av+1,av+ay do ab[an]=ab[an]:sub(1,au)..string.char(aw):rep(ax)..ab[an]:sub(au+ax+1)end else for an=av+1,av+(ay or#aw)do local az=aw[an-av]if az and ab[an]then if type(az)=="string"then ab[an]=ab[an]:sub(1,au)..az:sub(1,ax or-1)..ab[an]:sub(au+(ax or#az)+1)elseif type(az)=="table"then local l=""for am=1,ax or#az do l=l..string.char(az[am]or ab[an]:byte(au+am))end;ab[an]=ab[an]:sub(1,au)..l..ab[an]:sub(au+#l+1)end end end end;a8=true;a0.redraw()end;function a0.getPixels(au,av,ax,ay,l)a(1,au,"number")a(2,av,"number")a(3,ax,"number")a(4,ay,"number")a(5,l,"boolean","nil")local m={}for an=av+1,av+ay do if ab[an]then if l then m[an-av]=ab[an]:sub(au+1,au+ax)else m[an-av]={ab[an]:byte(au+1,au+ax)}if a1<2 then for w=1,ax do m[an-av][w]=2^m[an-av][w]end end end end end;return m end;a0.isColour=a0.isColor;a0.getTextColour=a0.getTextColor;a0.setTextColour=a0.setTextColor;a0.getBackgroundColour=a0.getBackgroundColor;a0.setBackgroundColour=a0.setBackgroundColor;a0.getPaletteColour=a0.getPaletteColor;a0.setPaletteColour=a0.setPaletteColor;function a0.getLine(an)if an<1 or an>U then return nil end;local aj,ak="",""for r in aa[an]:gmatch"."do aj,ak=aj..("%x"):format(bit32.band(r:byte(),0x0F)),ak..("%x"):format(bit32.rshift(r:byte(),4))end;return a9[an],aj,ak end;function a0.isVisible()return a5 end;function a0.setVisible(M)a(1,M,"boolean")a5=M;a0.redraw()end;function a0.redraw()if a5 and a8 then if X then if X.getGraphicsMode and(X.getGraphicsMode()or 0)~=a1 then X.setGraphicsMode(a1)end;if a1==0 then local q=X.getCursorBlink()X.setCursorBlink(false)for an=1,U do X.setCursorPos(A,Y+an-1)X.blit(a0.getLine(an))end;X.setCursorBlink(q)a0.restoreCursor()elseif X.drawPixels then X.drawPixels((A-1)*6,(Y-1)*9,ab,T,U)end;for w=0,X.getGraphicsMode and a1==2 and 255 or 15 do X.setPaletteColor(2^w,table.unpack(ac[w]))end end;if not a7 then local aA=""if a1==0 then local r,o=a9[1]:sub(1,1),0;for an=1,U do for aB in a9[an]:gmatch"."do if aB~=r or o==255 then aA=aA..r..string.char(o)r,o=aB,0 end;o=o+1 end end;if o>0 then aA=aA..r..string.char(o)end;r,o=aa[1]:sub(1,1),0;for an=1,U do for aB in aa[an]:gmatch"."do if aB~=r or o==255 then aA=aA..r..string.char(o)r,o=aB,0 end;o=o+1 end end;if o>0 then aA=aA..r..string.char(o)end else local r,o=ab[1]:sub(1,1),0;for an=1,U*9 do for aB in ab[an]:gmatch"."do if aB~=r or o==255 then aA=aA..r..string.char(o)r,o=aB,0 end;o=o+1 end end end;for w=0,a1==2 and 255 or 15 do aA=aA..string.char(ac[w][1]*255)..string.char(ac[w][2]*255)..string.char(ac[w][3]*255)end;S:send(af(0,V,string.pack("<BBHHHHBxxx",a1,a6 and 1 or 0,T,U,math.min(math.max(a2-1,0),0xFFFFFFFF),math.min(math.max(a3-1,0),0xFFFFFFFF),X and(X.isColor()and 0 or 1)or 0)..aA))end;a8=false end end;function a0.restoreCursor()if X then X.setCursorPos(A+a2-1,Y+a3-1)end end;function a0.getPosition()return A,Y end;function a0.reposition(aC,aD,aE,aF,aG)a(1,aC,"number","nil")a(2,aD,"number","nil")a(3,aE,"number","nil")a(4,aF,"number","nil")a(5,aG,"table","nil")A,Y,X=aC or A,aD or Y,aG or X;local resized=aE and aE~=T or aF and aF~=U;if aE then if aE<T then for an=1,U do a9[an],aa[an]=a9[an]:sub(1,aE),aa[an]:sub(1,aE)for w=1,9 do ab[(an-1)*9+w]=ab[(an-1)*9+w]:sub(1,aE*6)end end elseif aE>T then for an=1,U do a9[an],aa[an]=a9[an]..(" "):rep(aE-T),aa[an]..string.char(a4):rep(aE-T)for w=1,9 do ab[(an-1)*9+w]=ab[(an-1)*9+w]..("\x0F"):rep((aE-T)*6)end end end;T=aE end;if aF then if aF<U then for an=aF+1,U do a9[an],aa[an]=nil;for w=1,9 do ab[(an-1)*9+w]=nil end end elseif aF>U then for an=U+1,aF do a9[an],aa[an]=(" "):rep(T),string.char(a4):rep(T)for w=1,9 do ab[(an-1)*9+w]=("\x0F"):rep(T*6)end end end;U=aF end;if resized and not a7 then S:send(af(4,V,string.pack("<BBHHz",0,_ and 0 or os.computerID()%256,T,U,W)))end;a8=true;a0.redraw()end;if X.setTextScale then function a0.getTextScale()return X.getTextScale()end;function a0.setTextScale(aH)a(1,aH,"number")X.setTextScale(aH)T,U=X.getSize()if resized and not a7 then S:send(af(4,V,string.pack("<BBHHz",0,_ and 0 or os.computerID()%256,T,U,W)))end end end;function a0.pullEvent(aI,aJ,aK)a(1,aI,"string","nil")local aL;parallel.waitForAny(function()if a7 then while true do coroutine.yield()end end;while true do local aM=S:receive()if not aM then a7=true;error("Connection closed")end;if aM:sub(1,3)=="!CP"then local aN=8;if aM:sub(4,4)=='D'then aN=16 end;local aO=tonumber(aM:sub(5,aN),16)local ag=aM:sub(aN+1,aN+aO)local aP=tonumber(aM:sub(aN+aO+1,aN+aO+8),16)local C=t(ag)local aQ,aR=C:byte(1,2)if v(ae.binaryChecksum and C or ag)==aP then if aR==V then if aQ==1 then local aB,ae=C:byte(3,4)if bit32.btest(ae,8)then aL={"char",string.char(aB)}elseif not bit32.btest(ae,1)then aL={"key",e[aB],bit32.btest(ae,2)}else aL={"key_up",e[aB]}end;if not aI or aL[1]==aI then return else aL=nil end elseif aQ==2 then local aS,aT,aU,aV=string.unpack("<BBII",C,3)aL={N[aS],aS==2 and aT*2-1 or aT,aU,aV}if not aI or aL[1]==aI then return else aL=nil end elseif aQ==3 then local aW,aX=string.unpack("<Bz",C,3)aL={aX}local D=#aX+5;for w=2,aW+1 do aL[w],D=B(C,D)end;if not aI or aL[1]==aI then return else aL=nil end elseif aQ==4 then local ae,b,aY,aZ=string.unpack("<BBHH",C,3)if ae==0 then if aY~=0 and aZ~=0 then a0.reposition(nil,nil,aY,aZ,nil)aL={"term_resize"}end elseif ae==1 or ae==2 then a0.close()aL={"win_close"}end;if not aI or aL[1]==aI then return else aL=nil end elseif aQ==7 and ae.filesystem then local a_,b0,P,b1=string.unpack("<BBz",C,3)if a_==12 or a_==13 then b1=string.unpack("<z",C,b1)else b1=nil end;if bit32.band(a_,0xF0)==0 then local b2,J=pcall(O[a_],P,b1)if b2 then if type(J)=="boolean"then S:send(af(8,V,string.pack("<BBB",a_,b0,J and 1 or 0)))elseif type(J)=="number"then S:send(af(8,V,string.pack("<BBI4",a_,b0,J)))elseif type(J)=="string"then S:send(af(8,V,string.pack("<BBz",a_,b0,J)))elseif a_==8 then if J then S:send(af(8,V,string.pack("<BBI4I8I8BBBB",a_,b0,J.size,J.created or 0,J.modified or J.modification or 0,J.isDir and 1 or 0,J.isReadOnly and 1 or 0,0,0)))else S:send(af(8,V,string.pack("<BBI4I8I8BBBB",a_,b0,0,0,0,0,0,1,0)))end elseif type(J)=="table"then local b3=""for w=1,#J do b3=b3 ..J[w].."\0"end;S:send(af(8,V,string.pack("<BBI4",a_,b0,#J)..b3))else S:send(af(8,V,string.pack("<BBB",a_,b0,0)))end else if a_==0 or a_==1 or a_==2 then S:send(af(8,V,string.pack("<BBB",a_,b0,2)))elseif a_==3 or a_==5 or a_==6 then S:send(af(8,V,string.pack("<BBI4",a_,b0,0xFFFFFFFF)))elseif a_==4 or a_==7 or a_==9 then S:send(af(8,V,string.pack("<BBz",a_,b0,"")))elseif a_==8 then S:send(af(8,V,string.pack("<BBI4I8I8BBBB",a_,b0,0,0,0,0,0,2,0)))else S:send(af(8,V,string.pack("<BBz",a_,b0,J)))end end elseif bit32.band(a_,0xF0)==0x10 then local b4,b5=fs.open(P,Q[bit32.band(a_,7)])if b4 then if bit32.btest(a_,1)then ad[b0]=b4 else S:send(af(9,V,string.pack("<BBs4",0,b0,b4.readAll()or"")))b4.close()end else if bit32.btest(a_,1)then S:send(af(8,V,string.pack("<BBz",a_,b0,b5)))else S:send(af(9,V,string.pack("<BBs4",1,b0,b5)))end end end elseif aQ==9 and ae.filesystem then local b,b0,aO=string.unpack("<BBI4",C,3)local l=C:sub(9,aO+8)if ad[b0]~=nil then ad[b0].write(l)ad[b0].close()ad[b0]=nil;S:send(af(8,V,string.pack("<BBB",17,b0,0)))else S:send(af(8,V,string.pack("<BBz",17,b0,"Unknown request ID")))end end end end;if aQ==6 then ae.isVersion11=true;local b6=string.unpack("<H",C,3)if aR==V then S:send(af(6,aR,string.pack("<H",1+(Z and 0 or 2))))end;if bit32.btest(b6,0x01)then ae.binaryChecksum=true end;if bit32.btest(b6,0x02)and not Z then ae.filesystem=true end;if bit32.btest(b6,0x04)then S:send(af(4,V,string.pack("<BBHHz",0,_ and 0 or os.computerID()%256,T,U,W)))a8=true end end end end end,function()if aK then while true do coroutine.yield()end end;repeat aL=nil;aL=table.pack(os.pullEventRaw(aI))until not aJ or not R[aL[1]]end)return table.unpack(aL,1,aL.n or#aL)end;function a0.setTitle(G)a(1,W,"string")W=G;if a7 then return end;S:send(af(4,V,string.pack("<BBHHz",0,_ and 0 or os.computerID()%256,T,U,W)))end;function a0.sendMessage(type,W,b7)a(1,W,"string")a(2,b7,"string")a(3,type,"string","nil")if a7 then return end;local ae=0;if type=="error"then type=0x10 elseif type=="warning"then type=0x20 elseif type=="info"then type=0x40 elseif type then error("bad argument #3 (invalid type '"..type.."')",2)end;S:send(af(5,V,string.pack("<Izz",ae,W,b7)))end;function a0.close(b8)if a7 then return end;S:send(af(4,V,string.pack("<BBHHz",b8 and 1 or 2,0,0,0,"")))if S.close and not b8 then S:close()end;a7=true end;if X then for L,M in pairs(X)do if a0[L]==nil then a0[L]=M end end end;S:send(af(4,V,string.pack("<BBHHz",0,_ and 0 or os.computerID()%256,T,U,W)))return a0 end;function c.client(S,V,b9)a(1,S,"table")a(2,V,"number")a(3,b9,"table","nil")a.field(S,"send","function")a.field(S,"receive","function")a.field(S,"close","function","nil")a.field(S,"setTitle","function","nil")a.field(S,"showMessage","function","nil")a.field(S,"windowNotification","function","nil")local ba={}local ae={isVersion11=false,binaryChecksum=false,filesystem=false}local a7=false;local bb=0;local function af(type,V,C)local ag=k(string.char(type)..string.char(V or 0)..C)local s;if#C>65535 and ae.isVersion11 then s="!CPD"..string.format("%012X",#ag)else s="!CPC"..string.format("%04X",#ag)end;s=s..ag;if ae.binaryChecksum then s=s..("%08X"):format(v(string.char(type)..string.char(V or 0)..C))else s=s..("%08X"):format(v(ag))end;return s.."\n"end;local function bc(bd,type,be)local b6=function(P,b1)a(1,P,"string")if be then a(2,P,"string")end;local o=bb;S:send(af(7,V,string.pack(be and"<BBzz"or"<BBz",bd,o,P,b1)))bb=(bb+1)%256;local C;while not C or C:byte(4)~=o do C=ba.update(S:receive())end;if type=="nil"then local M=string.unpack("z",C,5)if M~=""then error(M,2)else return end elseif type=="boolean"then local M=C:byte(5)if M==2 then error("Failure",2)else return M~=0 end elseif type=="number"then local M=string.unpack("<I4",C,5)if M==0xFFFFFFFF then error("Failure",2)else return M end elseif type=="string"then local M=string.unpack("<I4",C,5)if M==""then error("Failure",2)else return M end elseif type=="table"then local aO=string.unpack("<I4",C,5)if aO==0xFFFFFFFF then error("Failure",2)end;local m,D={},9;for w=1,aO do m[w],D=string.unpack("z",C,D)end;return m elseif type=="attributes"then local bf,b5={}bf.size,bf.created,bf.modified,bf.isDir,bf.isReadOnly,b5=string.unpack("<I4I8I8BBB",C,5)if b5==1 then return nil elseif b5==2 then error("Failure",2)else return bf end end end;if be then return b6 else return function(P)return b6(P)end end end;local bg={exists=bc(0,"boolean"),isDir=bc(1,"boolean"),isReadOnly=bc(2,"boolean"),getSize=bc(3,"number"),getDrive=bc(4,"string"),getCapacity=bc(5,"number"),getFreeSpace=bc(6,"number"),list=bc(7,"table"),attributes=bc(8,"attributes"),find=bc(9,"table"),makeDir=bc(10,"nil"),delete=bc(11,"nil"),copy=bc(12,"nil",true),move=bc(13,"nil",true),open=function(P,a1)a(1,P,"string")a(2,a1,"string")local ao;for w=0,7 do if Q[w]==a1 then ao=w;break end end;if not ao then error("Invalid mode",2)end;if bit32.btest(ao,1)then local bh,bi="",false;return{write=function(s)if bi then error("attempt to use closed file",2)end;if bit32.btest(ao,4)and type(s)=="number"then bh=bh..string.char(s)else bh=bh..tostring(s)end end,writeLine=function(s)if bi then error("attempt to use closed file",2)end;bh=bh..tostring(s).."\n"end,flush=function()if bi then error("attempt to use closed file",2)end;local o=bb;S:send(af(7,V,string.pack("<BBz",16+ao,o,P)))S:send(af(9,V,string.pack("<BBs4",0,o,bh)))bb=(bb+1)%256;bh,ao="",bit32.bor(ao,2)local s;while not s or s:byte(4)~=o do s=ba.update(S:receive())end;local M=string.unpack("z",s,5)if M~=""then error(M,2)end end,close=function()if bi then error("attempt to use closed file",2)end;bi=true;local o=bb;S:send(af(7,V,string.pack("<BBz",16+ao,o,P)))S:send(af(9,V,string.pack("<BBs4",0,o,bh)))bb=(bb+1)%256;bh,ao="",bit32.bor(ao,2)local s;while not s or s:byte(4)~=o do s=ba.update(S:receive())end;local M=string.unpack("z",s,5)if M~=""then error(M,2)end end}else local o=bb;S:send(af(7,V,string.pack("<BBz",16+ao,o,P)))bb=(bb+1)%256;local s;while not s or s:byte(4)~=o do s=ba.update(S:receive())end;local aO=string.unpack("<I4",s,5)local C=s:sub(9,8+aO)if s:byte(3)~=0 then return nil,C end;local D,bi=1,false;return{read=function(o)a(1,o,"number","nil")if bi then error("attempt to use closed file",2)end;if D>=#C then return nil end;if o==nil then if bit32.btest(ao,4)then D=D+1;return C:byte(D-1)else o=1 end end;D=D+o;return C:sub(D-o,D-1)end,readLine=function(bj)if bi then error("attempt to use closed file",2)end;if D>=#C then return nil end;local bk,bl=D;bl,D=C:match("([^\n]"..(bj and"+)\n"or"*\n)").."()",D)if not D then bl=C:sub(D)D=#C end;return bl end,readAll=function()if bi then error("attempt to use closed file",2)end;if D>=#C then return nil end;local s=C:sub(D)D=#C;return s end,close=function()if bi then error("attempt to use closed file",2)end;bi=true end,seek=bit32.btest(ao,4)and function(bm,bn)a(1,bm,"string","nil")a(2,bn,"number","nil")bm=bm or"cur"bn=bn or 0;if bi then error("attempt to use closed file",2)end;if bm=="set"then D=bn elseif bm=="cur"then D=D+bn elseif bm=="end"then D=#C-bn else error("Invalid whence",2)end;return D end or nil}end end}function ba.update(b7)a(1,b7,"string")if b7:sub(1,3)=="!CP"then local aN=8;if b7:sub(4,4)=='D'then aN=16 end;local aO=tonumber(b7:sub(5,aN),16)local ag=b7:sub(aN+1,aN+aO)local aP=tonumber(b7:sub(aN+aO+1,aN+aO+8),16)local C=t(ag)if v(ae.binaryChecksum and C or ag)==aP then local aQ,aR=C:byte(1,2)if aR==V then if aQ==0 and b9 then local a1,bo,T,U,a2,a3,bp=string.unpack("<BBHHHHB",C,3)local r,o,D=string.unpack("c1B",C,17)b9.setCursorBlink(false)if b9.setVisible then b9.setVisible(false)end;if b9.getGraphicsMode and b9.getGraphicsMode()~=a1 then b9.setGraphicsMode(a1)end;b9.clear()if a1==0 then local ah={}for Y=1,U do ah[Y]=""for A=1,T do ah[Y]=ah[Y]..r;o=o-1;if o==0 then r,o,D=string.unpack("c1B",C,D)end end end;r=r:byte()for Y=1,U do local aj,ak="",""for A=1,T do aj,ak=aj..("%x"):format(bit32.band(r,0x0F)),ak..("%x"):format(bit32.rshift(r,4))o=o-1;if o==0 then r,o,D=string.unpack("BB",C,D)end end;b9.setCursorPos(1,Y)b9.blit(ah[Y],aj,ak)end else local ab={}for Y=1,U*9 do ab[Y]=""for A=1,T*6 do ab[Y]=ab[Y]..r;o=o-1;if o==0 then r,o,D=string.unpack("c1B",C,D)end end end;if b9.drawPixels then b9.drawPixels(0,0,ab)end end;D=D-2;local ar,as,q;if a1~=2 then for w=0,15 do ar,as,q,D=string.unpack("BBB",C,D)b9.setPaletteColor(2^w,ar/255,as/255,q/255)end else for w=0,255 do ar,as,q,D=string.unpack("BBB",C,D)b9.setPaletteColor(w,ar/255,as/255,q/255)end end;b9.setCursorBlink(bo~=0)b9.setCursorPos(a2+1,a3+1)if b9.setVisible then b9.setVisible(true)end elseif aQ==4 then local ae,b,aY,aZ,W=string.unpack("<BBHHz",C,3)if ae==0 then if aY~=0 and aZ~=0 and b9 and b9.reposition then local A,Y=b9.getPosition()b9.reposition(A,Y,aY,aZ)end;if S.setTitle then S:setTitle(W)end elseif ae==1 or ae==2 then if not a7 then S:send("\n")if S.close then S:close()end;a7=true end end elseif aQ==5 then local ae,W,aM=string.unpack("<Izz",C,3)local bq;if bit32.btest(ae,0x10)then bq="error"elseif bit32.btest(ae,0x20)then bq="warning"elseif bit32.btest(ae,0x40)then bq="info"end;if S.showMessage then S:showMessage(bq,W,aM)end elseif aQ==8 or aQ==9 then return C end elseif aQ==4 then local ae,b,aY,aZ,W=string.unpack("<BBHHz",C,3)if ae==0 and S.windowNotification then S:windowNotification(aR,aY,aZ,W)end end;if aQ==6 then ae.isVersion11=true;local b6=string.unpack("<H",C,3)if bit32.btest(b6,0x01)then ae.binaryChecksum=true end;if bit32.btest(b6,0x02)then ae.filesystem=true;ba.fs=bg end end end end end;function ba.queueEvent(aL,...)a(1,aL,"string")if a7 then return end;local br=table.pack(...)if aL=="key"then S:send(af(1,V,string.pack("<BB",f[br[1]],br[2]and 2 or 0)))elseif aL=="key_up"then S:send(af(1,V,string.pack("<BB",f[br[1]],1)))elseif aL=="char"then S:send(af(1,V,string.pack("<BB",br[1]:byte(),9)))elseif aL=="mouse_click"then S:send(af(2,V,string.pack("<BBII",0,br[1],br[2],br[3])))elseif aL=="mouse_up"then S:send(af(2,V,string.pack("<BBII",1,br[1],br[2],br[3])))elseif aL=="mouse_scroll"then S:send(af(2,V,string.pack("<BBII",2,br[1]<0 and 0 or 1,br[2],br[3])))elseif aL=="mouse_drag"then S:send(af(2,V,string.pack("<BBII",3,br[1],br[2],br[3])))elseif aL=="term_resize"then if b9 then local aY,aZ=b9.getSize()S:send(af(4,V,string.pack("<BBHHz",0,0,aY,aZ,"")))end else local n=""for w=1,br.n do n=n..I(br[w])end;S:send(af(3,V,string.pack("<Bz",br.n,aL)..n))end end;function ba.resize(aY,aZ)a(1,aY,"number")a(2,aZ,"number")if b9 and b9.reposition then local A,Y=b9.getPosition()b9.reposition(A,Y,aY,aZ)end;if a7 then return end;S:send(af(4,V,string.pack("<BBHHz",0,0,aY,aZ,"")))end;function ba.close()if a7 then return end;S:send(af(4,V,string.pack("<BBHHz",1,0,0,0,"")))S:send("\n")if S.close then S:close()end;a7=true end;function ba.run()parallel.waitForAny(function()while not a7 do local aM=S:receive()if aM==nil then a7=true else ba.update(aM)end end end,function()while true do local aL=table.pack(os.pullEventRaw())if aL[1]=="key"or aL[1]=="key_up"or aL[1]=="char"or aL[1]=="mouse_click"or aL[1]=="mouse_up"or aL[1]=="mouse_scroll"or aL[1]=="mouse_drag"or aL[1]=="paste"or aL[1]=="terminate"or aL[1]=="term_resize"then ba.queueEvent(table.unpack(aL,1,aL.n))end end end)end;ba.fs=nil;S:send(af(6,V,string.pack("<H",7)))return ba end;local bs,bt={},{}bs.__index,bt.__index=bs,bt;function bs:send(C)return self._ws.send(C)end;function bs:receive(bu)while true do local b,bv,bw,bx=os.pullEvent("websocket_message")if bv==self.url then return bw,bx end end end;function bs:close()return self._ws.close()end;function bt:send(C)return rednet.send(self._id,C,self._protocol)end;function bt:receive(bu)local by=os.startTimer(bu)repeat local aL={os.pullEvent()}if aL[1]=="rednet_message"and aL[2]==self._id and(not self._protocol or aL[4]==self._protocol)then os.cancelTimer(by)return aL[3]end until aL[1]=="timer"and aL[2]==by end;function c.wsDelegate(bz,bA)a(1,bz,"string")a(2,bA,"table","nil")local bB,b5=http.websocket(bz,bA)if not bB then return nil,b5 end;return setmetatable({_ws=bB,url=bz},bs)end;function c.rednetDelegate(V,bC)a(1,V,"number")a(2,bC,"string","nil")return setmetatable({_id=V,_protocol=bC or"ccpc_raw_terminal"},bt)end;return c