/*
 * Name:
 * mtjs_iepnghandler_solo.js
 *
 * Legal:
 * Copyright (c) 2008 Micah Tischler
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 *
 * Description:
 * Dependency-less version of mtjs_iepnghandler.
 *
 * Distribution site:
 * http://micahtischler.com/
 *
 * Versioning: 
 * "1.0"
 * $Id: mtjs_iepnghandler_solo.js 653 2008-08-12 18:34:11Z junior $
 *
 */

var mtjs_iepnghandler_solo=null;

function mtjs_iepnghandler_solo_class(){
  if (mtjs_iepnghandler_solo==null){
    mtjs_iepnghandler_solo=this;
    this.iemode=(navigator.userAgent.search("MSIE[ \t][5-6][.]")!=-1);
    if (this.iemode){
      this.pngs=new Array();
      this.bgstyles=new Array();
      this.uniq=0;
      this.base_url=location.href.replace(/\/[^/]*$/,"/");
      this.worklist=new Array();
      this.abort_thresh=5;
      this.blank_gif=false;
      this.css_list_background=new Array('backgroundAttachment','backgroundColor','backgroundImage','backgroundPosition','backgroundRepeat'),
      this.css_list_border=new Array('borderBottom','borderLeft','borderRight','borderTop'),
      this.css_list_classification=new Array('clear','cursor','display','float','position','visibility'),
      this.css_list_dimension=new Array('height','lineHeight','maxHeight','maxWidth','minHeight','minWidth','width'),
      this.css_list_font=new Array('fontFamily','fontSize','fontSizeAdjust','fontStretch','fontStyle','fontVariant','fontWeight'),
      this.css_list_list=new Array('listStyleImage','listStylePosition','listStyleType'),
      this.css_list_margin=new Array('marginBottom','marginLeft','marginRight','marginTop'),
      this.css_list_padding=new Array('paddingBottom','paddingLeft','paddingRight','paddingTop'),
      this.css_list_positioning=new Array('bottom','clip','left','overflow','position','right','top','verticalAlign','zIndex'),
      this.css_list_table=new Array('borderCollapse','borderSpacing','captionSide','emptyCells','tableLayout'),
      this.css_list_text=new Array('color','direction','lineHeight','letterSpacing','textAlign','textDecoration','textIndent','textTransform','whiteSpace','wordSpacing');

    }
  } else {
    alert("An mtjs_iepnghandler_solo instance already exists.");
  }
}

mtjs_iepnghandler_solo_class.prototype.bgscale = function(el,src){
  el.style.backgroundImage='none';
  el.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+src+"',sizingMethod='scale')";
}

mtjs_iepnghandler_solo_class.prototype.set_blank = function(url){
  this.blank_gif=url;
}

mtjs_iepnghandler_solo_class.prototype.gen_table = function(el,w,h){
  var tab, ti, row, i;

  tab=document.createElement("table");
  el.appendChild(tab);
  tab.setAttribute('border','0');
  tab.setAttribute('cellPadding','0');
  tab.setAttribute('cellSpacing','0');
  tab.appendChild(document.createElement("thead"));
  tab.appendChild(document.createElement("tfoot"));
  ti=document.createElement("tbody");
  tab.appendChild(ti);
  if (h>0){
    row=document.createElement("tr");
    ti.appendChild(row);
    for (i=0;i<w;i++){
      row.appendChild(document.createElement("td"));
    }
    for (i=1;i<h;i++){
      ti.appendChild(row.cloneNode(true));
    }
  }
  return tab;
}

mtjs_iepnghandler_solo_class.prototype.tiler = function(el,elstyle,png,bg,monox,monoy,elwidth,elheight){
  var newel=document.createElement("div"),
      posx=(bg.perx?Math.ceil((bg.posx/100.0)*(elwidth-png.width)):bg.posx)%png.width,
      posy=(bg.pery?Math.ceil((bg.posy/100.0)*(elheight-png.height)):bg.posy)%png.height,
      celx=bg.repx?(monox?1:Math.ceil(elwidth/(1.0*png.width))+((posx&&bg.repx)?1:0)):1,
      cely=bg.repy?(monoy?1:Math.ceil(elheight/(1.0*png.height))+((posy&&bg.repy)?1:0)):1,
      tab=this.gen_table(newel,celx,cely);
  this.inject_stepparent(el,newel);
  this.css_swap_dimpos(el,newel);
  newel.style.backgroundColor=elstyle.backgroundColor;
  newel.style.overflow='hidden';
  newel.style.zIndex=elstyle.zIndex;
  el.style.backgroundColor='transparent';
  el.style.backgroundImage='none';
  el.style.zIndex=1;
  tab.style.position='absolute';
  tab.style.width=elwidth+'px';
  tab.style.height=elheight+'px';
  tab.style.display='block';
  tab.style.top=posx+'px';
  tab.style.left=posy+'px';
  tab.style.zIndex=0;

  tab.className="mtjs_iepnghandler_class_"+this.uniq;
  this.css_append_rule(".mtjs_iepnghandler_class_"+this.uniq+" td",
    "filter: progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+png.src+"',sizingMethod='scale');"+
    "width: "+(monox?elwidth:png.width)+"px;"+
    "height: "+(monoy?elheight:png.height)+"px;");
  this.uniq++;
}

mtjs_iepnghandler_solo_class.prototype.diver = function(el,elstyle,png,bg){
  var newelo=this.dom_create("div"),
      neweli=this.dom_create("div"),
      divo=this.dom_create("div"),
      divi=this.dom_create("div"),
      parelstyle=this.css_get_style(el.parentNode);

  this.inject_stepparent(el,newelo);
  this.inject_stepparent(el,neweli);
  neweli.appendChild(divo);
  divo.appendChild(divi);

  this.css_swap_attrs(el,newelo,
    ['position','top','left','right','bottom','width','height',
    'margin','margin-top','margin-left','margin-right','margin-bottom']);
  newelo.style.backgroundColor=elstyle.backgroundColor;
  newelo.style.overflow='hidden';
  newelo.style.display='block';
  newelo.style.zIndex=elstyle.zIndex;

  neweli.style.position='relative';
  neweli.style.overflow='hidden';
  neweli.style.display='block';
  neweli.style.width='100%';
  neweli.style.height='100%';

  el.style.backgroundColor='transparent';
  el.style.backgroundImage='none';
  el.style.zIndex=1;

  divo.style.overflow='visible';
  divo.style.position='absolute';
  divo.style.left=bg.repx?'0px':bg.posx+(bg.perx?'%':'px');
  divo.style.top=bg.repy?'0px':bg.posy+(bg.pery?'%':'px');
  divo.style.width=bg.repx?'100%':'0px';
  divo.style.height=bg.repy?'100%':'0px';
  divo.style.display='block';
  divo.style.zIndex=0;

  divi.style.position='absolute';
  divi.style.width=bg.repx?'100%':png.width+'px';
  divi.style.height=bg.repy?'100%':png.height+'px';
  divi.style.display='block';
  divi.style.left=bg.perx?'-'+Math.round((bg.posx/100.0)*png.width)+'px':'0px';
  divi.style.top=bg.pery?'-'+Math.round((bg.posy/100.0)*png.height)+'px':'0px';
  divi.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+png.src+"',sizingMethod='scale')";
  divi.style.overflow='hidden';

}

mtjs_iepnghandler_solo_class.prototype.go = function(){
  if (this.iemode){
    this.css_walk();
    this.dom_walker(function (el) { return mtjs_iepnghandler_solo.inner_walk(el);});
    this.worker();
  }
}

mtjs_iepnghandler_solo_class.prototype.worker = function(){
  var curwork,
      status;
  if (this.worklist.length>0){
    curwork=this.worklist.shift();
    if (curwork[2]){
      status=this.process_img(curwork[0]);
    } else {
      status=this.process_bg(curwork[0]);
    }
    if (!status && (curwork[1]<this.abort_thresh)){
      curwork[1]++;
      this.worklist.push(curwork);
    }
    if (this.worklist.length>0){
      //Keep IE happy with non-blocking loop and reduce thrashing with something like Karn's Algy.
      setTimeout("mtjs_iepnghandler_solo.worker();",(this.worklist[0][1]>0)?this.worklist[0][1]*100:10);
    }
  }
}

mtjs_iepnghandler_solo_class.prototype.inner_walk = function(el){
  var elstyle=this.css_get_style(el);
  if ((el.tagName=='IMG')&&(el.src.search("[.][Pp][Nn][Gg][\'\"]*$")!=-1)){
    this.worklist.push([el,0,true]);
  } else {
    if ((elstyle.backgroundImage!='none')&&(elstyle.backgroundImage.search(/[.][Pp][Nn][Gg][\'\"]*\)/)!=-1)){
      this.worklist.push([el,0,false]);
    }
  }
  return false;
}

mtjs_iepnghandler_solo_class.prototype.process_img = function (el){
  if (el.complete){
    if (this.blank_gif){
      el.style.filter="progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+el.src+"',sizingMethod='scale')";
      el.src=this.blank_gif;
    } else {
      var elstyle=this.css_get_style(el),
          outer=this.dom_create('span'),
          inner=this.dom_create('span'),
          backer=this.dom_create('span'); 

      this.inject_stepparent(el,outer);
      this.inject_stepparent(el,inner);
      inner.appendChild(backer);

      this.css_swap_attrs(el,outer,this.css_list_classification);
      this.css_swap_attrs(el,outer,this.css_list_positioning);
      outer.style.display='inline';

      inner.style.position='relative';
      inner.style.display='inline';

      el.style.position='relative';
      el.style.top='0px';
      el.style.left='0px';
      el.style.visibility='hidden';
      el.style.zIndex=0;

      backer.style.position='absolute';
      backer.style.top='0px';
      backer.style.left='0px';
      backer.style.zIndex=1;
      backer.style.display='block';

      this.css_clone_attrs(el,backer,this.css_list_border);
      this.css_clone_attrs(el,backer,this.css_list_dimension);
      this.css_clone_attrs(el,backer,this.css_list_margin);
      this.css_clone_attrs(el,backer,this.css_list_padding);
      
      this.bgscale(backer,el.src);
    }
    return true;
  }
  return false;
}

mtjs_iepnghandler_solo_class.prototype.process_bg = function(el){
  var elstyle=this.css_get_style(el),
      png=this.pngs[this.check_png(elstyle.backgroundImage.replace(/(^.*\([\'\"]*|[\'\"]*\).*$)/g,""))];
  if (png.complete){
    var bg=new this.css_obj_parsebg(this.css_style_to_rule(el)),
        elwidth=(elstyle.width.replace(/[^0-9]/g,"")).replace(/^$/,document.body.clientWidth),
        elheight=(elstyle.height.replace(/[^0-9]/g,"")).replace(/^$/,document.body.clientHeight),
        monox=(png.width==1),
        monoy=(png.height==1);

    if (bg.repx){
      if (bg.repy){
        if (monox && monoy){
          this.bgscale(el,png.src);
        } else {
          this.tiler(el,elstyle,png,bg,monox,monoy,elwidth,elheight);
        }
      } else {
        if (monox){
          if (elstyle.height==png.height+'px'){
            this.bgscale(el,png.src);
          } else {
            this.diver(el,elstyle,png,bg);
          }
        } else {
          this.tiler(el,elstyle,png,bg,monox,monoy,elwidth,elheight);
        }
      }
    } else {
      if (bg.repy){
        if (monoy){
          if (elstyle.width==png.width+'px'){
            this.bgscale(el,png.src);
          } else {
            this.diver(el,elstyle,png,bg);
          }
        } else {
          this.tiler(el,elstyle,png,bg,monox,monoy,elwidth,elheight);
        }
      } else {
        this.diver(el,elstyle,png,bg);
      }
    }
    return true;
  }
  return false;
}

mtjs_iepnghandler_solo_class.prototype.check_png = function(src){
  if (this.iemode){
    var pngi;

    if (src.search(/^[Hh][Tt][Tt][Pp][:][/][/]/)==-1){
      src=this.base_url+src;
    }
    for (pngi=0;pngi<this.pngs.length;pngi++){
      if (src==this.pngs[pngi].src){
        break;
      }
    }
    if (pngi==this.pngs.length){
      var newpng=document.createElement("img");
      newpng.src=src;
      pngi=(this.pngs.push(newpng))-1;      
    }
    return pngi;
  }
  return false;
}

mtjs_iepnghandler_solo_class.prototype.add_bgstyle = function(seltext,bgobj){
  if (this.iemode){
    var newobj=new Object;    
    newobj.pngi=this.check_png(bgobj.image),
    newobj.seltext=seltext,
    newobj.bgstyle=bgobj;
    this.bgstyles.push(newobj);
  }
}

//////////////////////DOM ROLL-INS///////////////////////////////////////

mtjs_iepnghandler_solo_class.prototype.inject_stepparent = function(el,newel){
  if (el!=document.body){
    var elpar=el.parentNode,
        elbuf=new Array,
        eli,elj;
    for (eli=0;el!=elpar.childNodes[eli];eli++);
    for (elj=elpar.childNodes.length-1;elj>=eli;elj--){
      elbuf.push(elpar.childNodes[elj]);
      elpar.removeChild(elpar.childNodes[elj]);
    }
    elpar.appendChild(newel);
    newel.appendChild(elbuf.pop());
    while(elbuf.length>0){
      elpar.appendChild(elbuf.pop());
    }
    return true;
  }
  return false;
} 


mtjs_iepnghandler_solo_class.prototype.dom_walker = function(callback){
  var rootel=document.getElementsByTagName("html")[0],
      el=document.getElementsByTagName("body")[0],
      newel;

  while (el&&(el!=rootel)){
    if (el.nodeType==1){
      newel=callback(el);
      if (newel){
        el=newel;
        continue;
      }
    }
    if (el.firstChild){
      el=el.firstChild;
    } else {
      while (el&&(el!=rootel)){
        if (el.nextSibling){
          el=el.nextSibling;
          break;
        } else {
          el=el.parentNode;
        }
      }
    }
  }
}

mtjs_iepnghandler_solo_class.prototype.dom_create = function(type){
  var el=document.createElement(type);
  this.css_attr_defaults(el);
  return el;
}

//////////////////////CSS ROLL-INS///////////////////////////////////////

mtjs_iepnghandler_solo_class.prototype.css_get_style = function(el){
  var style;
  try {
    style=window.getComputedStyle(el,null);
  } 
  catch(e){
    style=el.currentStyle;
  }
  return style;
}

mtjs_iepnghandler_solo_class.prototype.css_append_rule = function(sel,style){
  try {
    document.styleSheets[document.styleSheets.length-1].insertRule(sel+" { "+style+" }",document.styleSheets[document.styleSheets.length-1].cssRules.length);
  }
  catch (e) {
    try {
      document.styleSheets[document.styleSheets.length-1].addRule(sel,style);
    } 
    catch (e) {}
  }
}

mtjs_iepnghandler_solo_class.prototype.css_clone_attrs = function(elin,elout,attrs){
  var elinstyle=this.css_get_style(elin),
      i,attr;
  for (i=0;i<attrs.length;i++){
    attr=attrs[i];
    if (elinstyle[attr]!=null){
      elout.style[attr]=elinstyle[attr];
    }
  }
}

mtjs_iepnghandler_solo_class.prototype.css_swap_attrs = function(elin,elout,attrs){
  var elinstyle=this.css_get_style(elin),
      eloutstyle=this.css_get_style(elout),
      styletmp,
      outswap,
      attr,
      i;
  for (i=0;i<attrs.length;i++){
    attr=attrs[i];
    if (eloutstyle[attr]!=null){
      styletmp=eloutstyle[attr];
      outswap=true;
    } else {
      outswap=false;
    }
    if (elinstyle[attr]!=null){
      elout.style[attr]=elinstyle[attr];
    }
    if (outswap){
      elin.style[attr]=styletmp;
    }
  }
}

mtjs_iepnghandler_solo_class.prototype.css_attr_to_rule = function(instyle,attr){
  var sstr=attr;
  sstr=sstr.replace(/[A-Z]/g,"-$&");
  return sstr.toLowerCase()+": "+instyle[attr]+";";      
} 

mtjs_iepnghandler_solo_class.prototype.css_style_to_rule = function(el){
  var elstyle=this.css_get_style(el),
      stylename,
      ruleout="{ ";
  for(stylename in elstyle){
    ruleout+=this.css_attr_to_rule(elstyle,stylename);
  }
  return ruleout+"}";
}

mtjs_iepnghandler_solo_class.prototype.css_swap_dimpos = function(elin,elout){
  this.css_swap_attrs(elin,elout,['position','top','left','right','bottom','width','height','float','clear']);
}

mtjs_iepnghandler_solo_class.prototype.css_attr_defaults = function(el){
  var es=el.style;
  es.border='0px';
  es.margin='0px';
  es.padding='0px';
  es.textAlign='left';
  es.background='transparent none no-repeat scroll 0px 0px';
}

mtjs_iepnghandler_solo_class.prototype.css_obj_parsebg = function(cssText){  
  var bgreg=new RegExp("[Bb][Aa][Cc][Kk][Gg][Rr][Oo][Uu][Nn][Dd][^:]*:[^;]+;","g"),
      cssstr=String(cssText),
      csstmp;

  this.image=false;
  this.color=false;
  this.fixed=false;
  this.repx=false;
  this.repy=false;
  this.posx=false;
  this.posy=false;
  this.perx=false;
  this.pery=false;
  
  if (cssstr.search(bgreg)==-1){
    return false;
  }

  cssstr=((cssstr.match(bgreg)).toString()).replace(/((^|;)[^:]+:|;[ \t]*$)/g,"");

  //process image
  csstmp=cssstr.match(/[Uu][Rr][Ll]\([^)]*\)/g);
  if (csstmp!=null){
    csstmp=(csstmp[csstmp.length-1]).replace(/([Uu][Rr][Ll]\(|\))/g,"");
    if (csstmp.length>0){
      this.image=csstmp;
    }
  }
  cssstr=cssstr.replace(/([ \t]|^)([Uu][Rr][Ll]\([^)]*\)|[Nn][Oo][Nn][Ee])([ \t]|$)/g," ");

  //process attachment
  if (cssstr.search(/([ \t]|^)[Ff][Ii][Xx][Ee][Dd]([ \t]|$)/)!=-1){
    this.fixed=true;
  }
  cssstr=cssstr.replace(/([ \t]|^)([Ff][Ii][Xx][Ee][Dd]|[Ss][Cc][Rr][Oo][Ll][Ll])([ \t]|$)/g," ");

  //process repeat
  csstmp=cssstr.match(/([ \t]|^)[Rr][Ee][Pp][Ee][Aa][Tt](-[XxYy])*([ \t]|$)/g);
  if (csstmp!=null){
    csstmp=csstmp[csstmp.length-1];
    if (csstmp.search(/[Tt]([ \t]|$)/)!=-1){
      this.repx=true;
      this.repy=true;
    } else {
      if (csstmp.search(/[Yy]([ \t]|$)/)!=-1){
        this.repy=true;
      } else {
        this.repx=true;
      }
    }
  }
  cssstr=cssstr.replace(/([ \t]|^)([Nn][Oo]-[Rr][Ee][Pp][Ee][Aa][Tt]|[Rr][Ee][Pp][Ee][Aa][Tt](-[XxYy])*)([ \t]|$)/g," ");
  
  //process position
  csstmp=cssstr.match(/([ \t]|^)((-?[0-9]+(px|[%])|[Tt][Oo][Pp]|[Cc][Ee][Nn][Tt][Ee][Rr]|[Bb][Oo][Tt][Tt][Oo][Mm]|[Ll][Ee][Ff][Tt]|[Rr][Ii][Gg][Hh][Tt])([ \t]|$))+/g);
  if (csstmp!=null){
    var i,p,s="",v;
    this.posx=50;
    this.posy=50;
    this.perx=true;
    this.pery=true;
    for (i=0;i<csstmp.length;i++){
      s+=csstmp[i];
    }
    csstmp=s.split(/[ \t]+/);
    for (i=0;i<csstmp.length;i++){
      s=csstmp[i];
      if (s.search(/[0-9]/)!=-1){
        v=s.match(/-*[0-9]+/);
        p=(s.search(/[%]/)!=-1);
        switch(i){
          case 0 : this.posx=v;
                   this.perx=p;
                   break;
          case 1 : this.posy=v;
                   this.pery=p;
                   break;
        }
      } else {
        if (s.search(/[Ll][Ee][Ff][Tt]/)!=-1){
          this.posx=0;
        } else {
          if (s.search(/[Tt][Oo][Pp]/)!=-1){
            this.posy=0;
          } else {
            if (s.search(/[Bb][Oo][Tt][Tt][Oo][Mm]/)!=-1){
              this.posy=100;
            } else {
              if (s.search(/[Rr][Ii][Gg][Hh][Tt]/)!=-1){
                this.posx=100;
              }
            }
          }
        }
      }
    }
  }
  cssstr=cssstr.replace(/([ \t]|^)((-?[0-9]+(px|[%])|[Tt][Oo][Pp]|[Cc][Ee][Nn][Tt][Ee][Rr]|[Bb][Oo][Tt][Tt][Oo][Mm]|[Ll][Ee][Ff][Tt]|[Rr][Ii][Gg][Hh][Tt])([ \t]|$))+/g," ");

  //process color ... the left-over
  cssstr=cssstr.replace(/[ \t]+/g,"");
  if (cssstr.length>0){
    this.color=cssstr;
  }

//  alert("image: "+this.image+"\ncolor: "+this.color+"\nfixed: "+this.fixed+"\nrepx: "+this.repx+"\nrepy: "+this.repy+"\nposx: "+this.posx+"\nposy: "+this.posy+"\nperx: "+this.perx+"\npery: "+this.pery);

}

///////////////////CSSWALKER ROLL-INS///////////////////////////////////////

mtjs_iepnghandler_solo_class.prototype.css_walk = function(){
  var regex='(',
      regexes=new Array(),
      regiter,
      sheetiter,
      rulelist,
      inneriter,
      iestyle=false;

  if (!document.styleSheets){
    return;
  }
  
  for(sheetiter=0;sheetiter<document.styleSheets.length;sheetiter++){
    rulelist=document.styleSheets[sheetiter].cssRules ? document.styleSheets[sheetiter].cssRules : document.styleSheets[sheetiter].rules;
    for (inneriter=0;inneriter<rulelist.length;inneriter++){
      var selectorText=rulelist[inneriter].selectorText,
          cssText=rulelist[inneriter].cssText?rulelist[inneriter].cssText:rulelist[inneriter].style.cssText,
          bg=new this.css_obj_parsebg(cssText);

      if (bg.image && (bg.image.search(/[.][Pp][Nn][Gg]$/)!=-1)){
        this.check_png(bg.image);
        if (!bg.posx && !bg.posy && !bg.repx && !bg.repy){
          this.css_append_rule(selectorText,"background-image:none; filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src='"+bg.image+"',sizingMethod='crop');");
        } else {
          //expansion hook
          this.add_bgstyle(selectorText,bg);
        }
      }
      
    }
  }
}

//////////////////////END ROLL-INS///////////////////////////////////////

new mtjs_iepnghandler_solo_class();