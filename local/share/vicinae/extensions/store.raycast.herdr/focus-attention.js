"use strict";var E=Object.defineProperty;var he=Object.getOwnPropertyDescriptor;var ye=Object.getOwnPropertyNames;var be=Object.prototype.hasOwnProperty;var xe=(e,r)=>{for(var t in r)E(e,t,{get:r[t],enumerable:!0})},Pe=(e,r,t,n)=>{if(r&&typeof r=="object"||typeof r=="function")for(let i of ye(r))!be.call(e,i)&&i!==t&&E(e,i,{get:()=>r[i],enumerable:!(n=he(r,i))||n.enumerable});return e};var Se=e=>Pe(E({},"__esModule",{value:!0}),e);var Ce={};xe(Ce,{default:()=>we});module.exports=Se(Ce);var N=require("@raycast/api");var B=require("node:fs/promises"),L=require("node:fs"),S=require("node:path"),D=require("node:os"),K=require("node:child_process");var z=require("@raycast/api");function w(){return(0,z.getPreferenceValues)()}var _,l=class extends Error{constructor(t,n,i){super(t);this.code=n;this.detail=i;this.name="HerdrError"}};async function $(e){try{return await(0,B.access)(e,L.constants.X_OK),!0}catch{return!1}}async function T(){let e=w().herdrPath?.trim();if(e){if(await $(e))return e;throw new l("The configured Herdr binary is not executable","binary_not_found",`Check the Herdr Binary preference: ${e}`)}if(_&&await $(_))return _;let r=[...(process.env.PATH||"").split(S.delimiter).filter(Boolean).map(t=>(0,S.join)(t,"herdr")),(0,S.join)((0,D.homedir)(),".local","bin","herdr"),"/opt/homebrew/bin/herdr","/usr/local/bin/herdr","/usr/bin/herdr"];for(let t of[...new Set(r)])if(await $(t))return _=t,t;throw new l("Herdr is not installed or could not be found","binary_not_found","Install it with `brew install herdr`, or set the Herdr Binary preference.")}function ve(e,r){for(let t of[r.trim(),e.trim()])if(t)try{let n=JSON.parse(t);if(n.error)return new l(n.error.message||"Herdr command failed",n.error.code,t)}catch{}}async function v(e,r={}){let t=await T(),n=w(),i=r.session??n.sessionName?.trim(),o={...process.env};return i&&i!=="default"?o.HERDR_SESSION=i:delete o.HERDR_SESSION,new Promise((s,d)=>{(0,K.execFile)(t,e,{env:o,timeout:r.timeout??3e4,maxBuffer:16*1024*1024,encoding:"utf8"},(u,c,a)=>{let g=ve(c,a);if(g)return d(g);if(u){let f=a.trim()||c.trim()||u.message,b="killed"in u&&u.killed;return d(new l(b?"The Herdr command timed out":"Unable to run the Herdr command",b?"timeout":"command_failed",f))}s(c)})})}async function P(e,r={}){let t=await v(e,r);try{let n=JSON.parse(t);if(n.error)throw new l(n.error.message||"Herdr command failed",n.error.code,t);return n.result===void 0?n:n.result}catch(n){throw n instanceof l?n:new l("Herdr returned an unexpected response","invalid_json",t.slice(0,2e3))}}async function U(){let e=await P(["api","snapshot"]);if(!e.snapshot)throw new l("Herdr did not return a session snapshot","invalid_snapshot");return e.snapshot}async function j(e,r){if(e==="pane"){await Te(r);return}await v([e,"focus",r])}async function Te(e){let r=await P(["pane","get",e]);await v(["tab","focus",r.pane.tab_id]);let n=(await P(["pane","layout","--pane",e])).layout.focused_pane_id;if(n===e)return;let i=["left","right","up","down"],o=new Map,s=new Set([n]),d=[n];for(;d.length>0&&!s.has(e);){let a=d.shift(),g=await Promise.all(i.map(async f=>{let b=await P(["pane","neighbor","--direction",f,"--pane",a]);return{direction:f,paneId:b.neighbor.neighbor_pane_id}}));for(let f of g)!f.paneId||s.has(f.paneId)||(s.add(f.paneId),o.set(f.paneId,{from:a,direction:f.direction}),d.push(f.paneId))}if(!s.has(e))throw new l("Herdr could not find a focus path to the selected pane","pane_focus_path_not_found");let u=[],c=e;for(;c!==n;){let a=o.get(c);if(!a)throw new l("Herdr returned an incomplete pane layout","invalid_pane_layout");u.unshift({from:a.from,to:c,direction:a.direction}),c=a.from}for(let a of u)await v(["pane","focus","--direction",a.direction,"--pane",a.from])}function G(e){return e.name||e.pane_id}function J(e){return e instanceof l?{title:e.message,message:e.detail}:e instanceof Error?{title:e.message}:{title:"Unexpected Herdr error",message:String(e)}}var C=require("node:child_process"),ce=require("node:crypto"),y=require("node:fs/promises"),k=require("node:path"),ue=require("node:os");var te=require("node:child_process"),ne=require("node:path");var H=require("node:path");function A(e){return`"${e.replaceAll("\\","\\\\").replaceAll('"','\\"').replaceAll(`
`,"\\n")}"`}function ke(e,r){let t=r?.trim(),n=e.match(/(?:^|\s)--session(?:=|\s+)([^\s]+)/)?.[1],i=e.match(/(?:^|\s)session\s+attach\s+([^\s]+)/)?.[1];return!t||t==="default"?!n&&!i:n===t||i===t}function q(e,r,t){let n=(0,H.basename)(r),i=[];for(let o of e.split(`
`)){let s=o.trim().match(/^(\S+)\s+(\S+)\s+(.+)$/);if(!s)continue;let[,d,,u]=s;if(d==="??"||d==="?")continue;let c=u.trim().split(/\s+/,1)[0].replace(/^['"]|['"]$/g,"");(0,H.basename)(c)!==n&&(0,H.basename)(c)!=="herdr"||ke(u,t)&&i.push(d.startsWith("/dev/")?d:`/dev/${d}`)}return[...new Set(i)]}function Q(e){return`set targetTtys to {${e.map(A).join(", ")}}
tell application "Terminal"
  repeat with w in windows
    repeat with t in tabs of w
      if targetTtys contains (tty of t) then
        set selected of t to true
        set frontmost of w to true
        activate
        return tty of t
      end if
    end repeat
  end repeat
  return "miss"
end tell`}function V(e){return`tell application "iTerm"
  set matches to every session of every tab of every window whose ${e.map(t=>`tty is ${A(t)}`).join(" or ")}
  repeat with windowIndex from 1 to count matches
    set windowMatches to item windowIndex of matches
    repeat with tabIndex from 1 to count windowMatches
      set tabMatches to item tabIndex of windowMatches
      if (count tabMatches) > 0 then
        set w to item windowIndex of windows
        set tb to item tabIndex of tabs of w
        set s to item 1 of tabMatches
        select w
        select tb
        select s
        activate
        return tty of s
      end if
    end repeat
  end repeat
  return "miss"
end tell`}function Y(e){return`tell application "Ghostty"
  ignoring case
    repeat 5 times
      repeat with t in terminals
        if (name of t as text) is ${A(e)} then
          focus t
          return "focused"
        end if
      end repeat
      delay 0.02
    end repeat
  end ignoring
  return "miss"
end tell`}function Z(e){return`tell application "Ghostty"
  ignoring case
    repeat with t in terminals
      if (name of t as text) is ${A(e)} then
        set name of t to "herdr"
        return "cleared"
      end if
    end repeat
  end ignoring
  return "miss"
end tell`}function X(e,r){let t;try{t=JSON.parse(e)}catch{return}let n=t.find(i=>i.tty_name&&r.includes(i.tty_name));return n?String(n.pane_id):void 0}function ee(e){let r;try{r=JSON.parse(e)}catch{return}let t=r.find(n=>Number.isInteger(n.window_id))?.window_id;return t===void 0?void 0:String(t)}function _e(e,r,t){return new Promise((n,i)=>{(0,te.execFile)(e,r,{timeout:t,encoding:"utf8"},(o,s)=>o?i(o):n(s.trim()))})}function He(e){return typeof e=="object"&&e!==null&&"code"in e&&e.code===1}async function M(e,r,t,n=_e){let i;try{i=await n("/usr/bin/pgrep",["-x",(0,ne.basename)(e)],t)}catch(s){return He(s)?[]:void 0}let o=i.split(/\s+/).filter(s=>/^\d+$/.test(s)).join(",");if(o)try{let s=await n("/bin/ps",["-p",o,"-o","tty=,comm=,args="],t);return q(s,e,r)}catch{return}}function re(e){let r=[],t="",n,i=!1,o=!1;for(let s of e.trim()){if(i){t+=s,i=!1,o=!0;continue}if(s==="\\"&&n!=="single"){i=!0,o=!0;continue}if(s==="'"&&n!=="double"){n=n==="single"?void 0:"single",o=!0;continue}if(s==='"'&&n!=="single"){n=n==="double"?void 0:"double",o=!0;continue}if(/\s/.test(s)&&!n){o&&(r.push(t),t="",o=!1);continue}t+=s,o=!0}if(i)throw new Error("Arguments cannot end with an unescaped backslash.");if(n)throw new Error(`Arguments contain an unterminated ${n} quote.`);return o&&r.push(t),r}function I(e){return e===""?"''":`'${e.replaceAll("'","'\\''")}'`}function O(e){let r=`${e?.bundleId||""} ${e?.name||""} ${e?.path||""}`.toLowerCase();return r.includes("com.apple.terminal")||/(?:^|\s|\/)terminal(?:\.app)?(?:\s|$)/.test(r)?"terminal":r.includes("iterm")||r.includes("com.googlecode.iterm2")?"iterm":r.includes("ghostty")?"ghostty":r.includes("wezterm")?"wezterm":r.includes("kitty")?"kitty":r.includes("alacritty")?"alacritty":r.includes("warp")?"warp":"generic"}function ie(e,r,t){let n=re(e);if(n.length===0)throw new Error("The Custom Terminal Launcher preference is empty.");let i=[];for(let o of n)o==="{herdr}"?i.push(r):o==="{args}"?i.push(...t):o==="{command}"?i.push([r,...t].map(I).join(" ")):i.push(o.replaceAll("{herdr}",r));if(!e.includes("{herdr}")&&!e.includes("{command}"))throw new Error("Custom Terminal Launcher must contain {herdr} or {command}.");return[i[0],i.slice(1)]}var x=450,oe=250;function de(e,r,t=5e3){return new Promise((n,i)=>{(0,C.execFile)(e,r,{timeout:t,encoding:"utf8"},(o,s)=>o?i(o):n(s.trim()))})}async function p(e,r,t){await de(e,r,t)}async function h(e,r,t){try{return await de(e,r,t)}catch{return}}function F(e){return`"${e.replaceAll("\\","\\\\").replaceAll('"','\\"').replaceAll(`
`,"\\n")}"`}function se(e,r){return new Promise((t,n)=>{let i=(0,C.spawn)(e,r,{detached:!0,stdio:"ignore"});i.once("error",n),i.once("spawn",()=>{i.unref(),t()})})}function W(){return w().terminalApplication}function ae(){return w().sessionName?.trim()||"default"}function le(e){if(e?.path)return(0,k.join)(e.path,"Contents","MacOS","wezterm")}async function R(){let e=W();e?.bundleId?await p("/usr/bin/open",["-b",e.bundleId]):e?.path?await p("/usr/bin/open",[e.path]):e?.name?await p("/usr/bin/open",["-a",e.name]):await p("/usr/bin/open",["-a","Terminal"])}async function Ae(){let e=W(),r=O(e||{bundleId:"com.apple.Terminal",name:"Terminal",path:""});if(r==="terminal"||r==="iterm"){let t=await T(),n=await M(t,ae(),oe);if(n===void 0)return"unavailable";if(n.length===0)return"missing";let i=r==="terminal"?Q(n):V(n),o=await h("/usr/bin/osascript",["-e",i],x);return o===void 0?"unavailable":o==="miss"?"missing":"focused"}if(r==="ghostty"){let t=`herdr-raycast-${(0,ce.randomUUID)()}`,n=!1;try{let i=await P(["terminal","title","set",t],{timeout:x});if(!i.changed)return i.reason==="no_foreground_client"?"missing":"unavailable";n=!0;let o=Y(t),s=await h("/usr/bin/osascript",["-e",o],x);return s===void 0?"unavailable":s==="focused"?"focused":"unavailable"}catch{return"unavailable"}finally{if(n){let i=Z(t);await h("/usr/bin/osascript",["-e",i],x)===void 0&&await h("/usr/bin/osascript",["-e",i],5e3)}}}if(r==="wezterm"){let t=le(e);if(!t)return"unavailable";let[n,i]=await Promise.all([h(t,["cli","list","--format","json"],x),T()]);if(!n)return"unavailable";let o=await M(i,ae(),oe);if(o===void 0)return"unavailable";let s=X(n,o);return s?await h(t,["cli","activate-pane","--pane-id",s],x)===void 0?"unavailable":(await R(),"focused"):"missing"}return"unavailable"}async function fe(){if(String(w().terminalFocusBehavior||"open")==="none")return!1;let e=await Ae();return e==="missing"?await pe():e==="unavailable"&&await R(),!0}async function Ie(e,r){let t=await(0,y.mkdtemp)((0,k.join)((0,ue.tmpdir)(),"herdr-raycast-")),n=(0,k.join)(t,"Open Herdr.command");await(0,y.writeFile)(n,`#!/bin/zsh
exec ${r}
`,{encoding:"utf8",mode:448}),await(0,y.chmod)(n,448),await p("/usr/bin/open",["-na",e,n]),setTimeout(()=>void(0,y.rm)(t,{recursive:!0,force:!0}).catch(()=>{}),6e4).unref()}async function pe(e=[],r={}){let t=await T(),n=W(),i=r.includePreferredSession===!1?void 0:w().sessionName?.trim(),o=i&&i!=="default"?["--session",i,...e]:e,s=[t,...o].map(I).join(" "),d=w().customTerminalLauncher?.trim();if(d){let[a,g]=ie(d,t,o);await se(a,g);return}let u=O(n||{bundleId:"com.apple.Terminal",name:"Terminal",path:""});if(u==="terminal"){let a=`tell application "Terminal"
activate
do script ${F(s)}
end tell`;await p("/usr/bin/osascript",["-e",a]);return}if(u==="iterm"){let a=`tell application "iTerm"
activate
if (count windows) > 0 then
  set targetWindow to current window
  set targetTab to create tab with default profile targetWindow
  set targetSession to current session of targetTab
else
  set targetWindow to create window with default profile
  set targetSession to current session of targetWindow
end if
tell targetSession to write text ${F(s)}
end tell`;await p("/usr/bin/osascript",["-e",a]);return}let c=n?.path||n?.name;if(!c){await p("/usr/bin/open",["-a","Terminal"]);return}if(u==="ghostty"){let a=`tell application "Ghostty"
activate
set cfg to new surface configuration
set command of cfg to ${F(s)}
if (count windows) > 0 then
  new tab in front window with configuration cfg
else
  new window with configuration cfg
end if
return "opened"
end tell`;if(await h("/usr/bin/osascript",["-e",a],1500)==="opened")return;await p("/usr/bin/open",["-na",c,"--args","-e",t,...o]);return}if(u==="alacritty"){await p("/usr/bin/open",["-na",c,"--args","-e",t,...o]);return}if(u==="wezterm"){let a=le(n);if(a){let g=await h(a,["cli","list","--format","json"],x),f=g?ee(g):void 0,b=await h(a,["cli","spawn",...f?["--window-id",f]:["--new-window"],"--",t,...o],750);if(b&&/^\d+$/.test(b)){await R();return}}await p("/usr/bin/open",["-na",c,"--args","start","--",t,...o]);return}if(u==="kitty"){let a=n?.path?(0,k.join)(n.path,"Contents","MacOS","kitty"):void 0;a?await se(a,[t,...o]):await p("/usr/bin/open",["-na",c,"--args",t,...o]);return}if(u==="warp"){await Ie(c,s);return}await p("/usr/bin/open",["-na",c,"--args","-e",t,...o])}var m=require("@raycast/api");var ge=require("react/jsx-runtime");async function me(e,r,t={}){let n=await(0,m.showToast)({style:m.Toast.Style.Animated,title:e});try{return await r(),await t.onSuccess?.(),n.style=m.Toast.Style.Success,n.title=t.success||e.replace(/^\w+ing\b/,"Done"),!0}catch(i){let o=J(i);return n.style=m.Toast.Style.Failure,n.title=o.title,n.message=o.message,!1}}async function we(){await me("Finding an agent",async()=>{let r=await U(),t=r.agents.find(n=>n.agent_status==="blocked")||r.agents.find(n=>n.agent_status==="done");if(!t)throw new l("No agent currently needs attention","no_attention_agent");await j("agent",G(t)),await fe()},{success:"Agent Focused"})&&await(0,N.closeMainWindow)({clearRootSearch:!0})}
