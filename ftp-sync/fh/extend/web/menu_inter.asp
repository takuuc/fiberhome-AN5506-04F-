<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>WebServer</title>
<meta http-equiv="Content-Type" content="text/html; charset=gbk">
<link type="text/css" rel="stylesheet" href="./style/frame_inter.css" id="css"/>
<script type="text/javascript" src="./lang/b28n.js"></script>
<script type="text/javascript" src="/js/utils.js"></script>
<script type="text/javascript" src="./js/versionControl.js"></script>
<script type="text/javascript" src="./js/jquery.js"></script>
<script type="text/javascript" src="./js/menu_tips.js"></script>
<script type="text/javascript" src="./js/frame.js"></script>
<script type="text/javascript" src="./js/menuParse.js"></script>
<script language="JavaScript" type="text/javascript">

/*  asp 页面中加入用户是否LOGIN的检查begin*/
var  checkResult = '<% cu_web_access_control(  ) ;%>'
web_access_check( checkResult) ;
/*  加入用户是否LOGIN的检查end*/

var lang = '<% getCfgGeneral(1, "language"); %>';
Butterlate.setTextDomain("menu", lang);

var curUserType = '<% getCfgGeneral(1, "curUserType");%>';

var menuPath = '<% getCfgZero("1", "menuPath");%>';
var ispName = '<% getCfgGeneral(1, "ispNameCode"); %>';
var ispMinorNameCode = '<% getCfgGeneral(1, "ispMinorNameCode"); %>';
var page_style = '<% getCfgGeneral(1, "page_style"); %>';

Frame.show(curUserType, menuPath,ispName);

function LoadFrame()
{
	document.getElementById("headerLogoutSpan").innerHTML = _("logout");
	document.getElementById("headerLogoImg").style.background = "url(" 
		+ getLogoVerCtrl(ispName, ispMinorNameCode, page_style) + ") no-repeat center";
	if(ispName == '12')//ECUADOR
	{
		var obj = document.getElementById("css");
		obj.setAttribute("href","./style/frame_ecuador.css");
	}
	else if(ispName == '16')/* 越南 HGU */
	{
		getElement("headerTopSpace").style.backgroundColor = "#216F6F";
	}
	else if(ispName == '27')/* 伊朗IRAN_NET */
	{
		getElement("css").href = "./style/frame_iranian.css";
	}
}
</script>
</head>
<body onload="LoadFrame()">
<div id="main">
  <div id="header" >
    <div id="headerTopSpace">&nbsp;</div>
    <div id="headerLogoImg"></div>
    <div id="headerContent">
      <div id="headerInfo">
        <div id="headerTitle">
          <b>Manajemen Ruter AP</b>
        </div>
        <div id="headerLogout"><span id="headerLogoutSpan">Logout</span></div>
      </div>
      <div id="headerTab">
        <ul>
        </ul>
      </div>
    </div>
    <div id="headerSpace">&nbsp;</div>
  </div>
  <div style="height: 495px;" id="center">
    <div style="height: 495px;" id="nav">
     <div id="navsub">
      <ul>
      </ul>
      </div>
    </div>
    <div style="height: 495px;" id="content">
      <div id="topNav"><span id="topNavMainMenu"></span>&nbsp;&#187;&nbsp;<span id="topNavSubMenu"></span>&nbsp;&#187;&nbsp;<span id="topNavSub2Menu"></span></div>
      <div style="height: 470px;" id="frameWarpContent">
        <iframe style="display: inline; height: 470px;" id="frameContent" marginheight="0" marginwidth="0"  frameborder="0" height="100%" width="100%"></iframe>
      </div>
    </div>
  </div>
  <div id="footer">
    <table border="0" cellpadding="0" cellspacing="0">
      <tbody>
        <tr>
          <td id="footerText"></td>
        </tr>
      </tbody>
    </table>
  </div>
  <div id="fresh"> </div>
  <div id="blockdiv" style="display:none;text-align:center;border-radius:25px"></div>
</div>
</body>
</html>
