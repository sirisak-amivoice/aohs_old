DynamicScript=function(b,c){var READY_STATE_UNINITIALIZED="uninitialized";var READY_STATE_LOADING="loading";var READY_STATE_LOADED="loaded";var READY_STATE_INTERACTIVE="interactive";var READY_STATE_COMPLETE="complete";var READY_STATE_ABORTED="aborted";var READY_STATE_TIMEOUT="timeout";var READY_STATE_ERROR="error";var REQUEST_FLAG_SERIALIZED=1;var REQUEST_FLAG_AVOID_CACHE=2;var REQUEST_FLAG_REMOVE_SCRIPT=4;var requestID=0;var defaultTimeout=-1;var defaultCharset=null;var domainList=new Object();var regExpHost=new RegExp("(http|https)://([^\\/]*).*","ig");var regExpProtocolHost=new RegExp("((http|https|ftp)://[^\\/]*).*","ig");function g(h,j){if(h==null||typeof h=="undefined")return false;if(j!=null&&typeof j=="string")return typeof h==j;return true;}if(g(b,"number"))defaultTimeout=b;if(g(c,"string"))defaultCharset=c;function k(l){var rMatch=null;regExpHost.lastIndex=0;rMatch=regExpHost.exec(l);return rMatch?rMatch[2]:"".toLowerCase();}function m(n){var rMatch=null;regExpProtocolHost.lastIndex=0;rMatch=regExpProtocolHost.exec(n);return rMatch?rMatch[1]:"".toLowerCase();}function o(p){var strLowerUrl=p.toLowerCase();if(strLowerUrl.substr(0,7)=="http://"||strLowerUrl.substr(0,8)=="https://")return p;var strBase=location.href.substring(0,location.href.lastIndexOf("/")+1);var objBases=document.getElementsByTagName("base");if(objBases.length>0&&objBases[0].href!="")strBase=objBases[0].href;if(strBase.charAt(strBase.length-1)!="/")strBase+="/";if(p.charAt(0)=="/")return m(strBase)+p;else return strBase+p;}Request=function(q,r,s,t,u,v,w){this.domain=q;this.url=r;this.context=s;this.callback=t;this.requestFlag=u;this.timeout=v;this.readyState=READY_STATE_UNINITIALIZED;this.requestID=-1;this.charset=w;};RequestPool=function(){var requestList=new Object();var serialQueue=new Array();var parallelPool=new Object();function x(y,z,A){if(y.indexOf("?")==-1)return y+"?"+z+"="+escape(A);else return y+"&"+z+"="+escape(A);}function B(C){return "DynamicScript_"+C;}function D(E){if(g(requestList[E.requestID])){delete requestList[E.requestID];if(E.requestFlag&REQUEST_FLAG_SERIALIZED)for(var i=0;i<serialQueue.length;i++){if(serialQueue[i].requestID==E.requestID)serialQueue.splice(i,1);}else delete parallelPool[E.requestID];}if(E.requestFlag&REQUEST_FLAG_REMOVE_SCRIPT){var objHeader=document.getElementsByTagName("head").item(0);var objScript=document.getElementById(B(E.requestID));if(objScript!=null){objHeader.removeChild(objScript);objScript.onreadystatechange=null;objScript.onload=null;objScript.onerror=null;}}window.setTimeout(H,1);}function F(G){var scriptID=B(G.requestID);var objHeader=document.getElementsByTagName("head").item(0);var objScript=document.getElementById(scriptID);if(objScript!=null)objHeader.removeChild(objScript);objScript=document.createElement("script");objScript.type="text/javascript";objScript.setAttribute("id",scriptID);if(g(G.charset,"string"))objScript.charset=G.charset;objScript.onreadystatechange=function(){if(objScript.readyState==READY_STATE_LOADED||objScript.readyState==READY_STATE_COMPLETE){if(G.readyState==READY_STATE_LOADING)G.readyState=READY_STATE_LOADED;if(g(G.callback,"function"))G.callback(G.context,G.readyState);if(G.readyState==READY_STATE_LOADED)G.readyState=READY_STATE_COMPLETE;D(G);}};objScript.onload=function(){objScript.readyState=READY_STATE_LOADED;objScript.onreadystatechange();};objScript.onerror=function(){G.readyState=READY_STATE_ERROR;if(g(G.callback,"function")){G.callback(G.context,G.readyState);G.callback=null;}D(G);};G.readyState=READY_STATE_LOADING;if(G.requestFlag&REQUEST_FLAG_AVOID_CACHE){var dtRef=new Date();objScript.setAttribute("src",x(G.url,"ver",dtRef.getTime()));}else objScript.setAttribute("src",G.url);objHeader.appendChild(objScript);if(G.timeout!=-1)window.setTimeout(function(){if(G.readyState==READY_STATE_LOADING){G.readyState=READY_STATE_TIMEOUT;if(g(G.callback,"function")){G.callback(G.context,G.readyState);G.callback=null;}D(G);}},G.timeout);}function H(){for(var id in parallelPool){if(parallelPool[id].readyState==READY_STATE_UNINITIALIZED)F(parallelPool[id]);}if(serialQueue.length>0){if(serialQueue[0].readyState==READY_STATE_UNINITIALIZED)F(serialQueue[0]);}}this.Add=function(I){if(I.readyState!=READY_STATE_UNINITIALIZED)return false;I.requestID=requestID++;if(I.requestFlag&REQUEST_FLAG_SERIALIZED)serialQueue.push(I);else parallelPool[I.requestID]=I;requestList[I.requestID]=I;H();return true;};this.Abort=function(J){if(J.readyState==READY_STATE_ABORTED)return false;J.readyState=READY_STATE_ABORTED;if(g(J.callback,"function")){J.callback(J.context,J.readyState);J.callback=null;}D(J);return true;};this.AbortAll=function(){for(var prop in requestList){this.Abort(requestList[prop]);}};};function K(L){if(!g(domainList[L.domain]))domainList[L.domain]=new RequestPool();return domainList[L.domain].Add(L);}function M(N){if(!g(domainList[N.domain]))return false;return domainList[N.domain].Abort(N);}this.AbortAll=function(){for(var prop in domainList){if(domainList[prop].AbortAll!=null&&typeof domainList[prop].AbortAll=="function")try{domainList[prop].AbortAll();}catch(e){}}};this.CreateRequest=function(O,P,Q,R,S,T){if(!g(O,"string")||!g(Q,"function"))return null;O=o(O);var strDomain=k(O);if(strDomain=="")return null;if(!g(S,"number"))S=defaultTimeout;if(!g(R,"number"))R=0;if(!g(T,"string"))T=defaultCharset;var objRequest=new Request(strDomain,O,P,Q,R,S,T);objRequest.Execute=function(){return K(objRequest);};objRequest.Abort=function(){return M(objRequest);};return objRequest;};};