﻿<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title><#Web_Title#> - System Information</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<style>
p{
	font-weight: bolder;
}
</style>

<script language="JavaScript" type="text/javascript" src="/state.js"></script>
<script language="JavaScript" type="text/javascript" src="/general.js"></script>
<script language="JavaScript" type="text/javascript" src="/popup.js"></script>
<script language="JavaScript" type="text/javascript" src="/help.js"></script>
<script language="JavaScript" type="text/javascript" src="/detect.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmhist.js"></script>
<script language="JavaScript" type="text/javascript" src="/tmmenu.js"></script>
<script language="JavaScript" type="text/javascript" src="/nameresolv.js"></script>
<script language="JavaScript" type="text/javascript" src="/jquery.js"></script>
<script language="JavaScript" type="text/javascript" src="/jquery.xdomainajax.js"></script>
<script>

wan_route_x = '<% nvram_get("wan_route_x"); %>';
wan_nat_x = '<% nvram_get("wan_nat_x"); %>';
wan_proto = '<% nvram_get("wan_proto"); %>';

hwacc = "<% nvram_get("ctf_disable"); %>";
hwacc_force = "<% nvram_get("ctf_disable_force"); %>";
arplist = [<% get_arp_table(); %>];
etherstate = "<% sysinfo("ethernet"); %>";
odmpid = "<% nvram_get("odmpid");%>";
ctf_fa = "<% nvram_get("ctf_fa_mode"); %>";

var $j = jQuery.noConflict();

overlib_str_tmp = "";
overlib.isOut = true;

function initial(){
	show_menu();
	if (!band5g_support) $("wifi5_clients_tr").style.display = "none";
	showbootTime();

	if (odmpid != "")
		$("model_id").innerHTML = odmpid;
	else
		$("model_id").innerHTML = productid;

	var buildno = '<% nvram_get("buildno"); %>';
	var firmver = '<% nvram_get("firmver"); %>';
	var extendno = '<% nvram_get("extendno"); %>';

	var conn_wifi_2g_assoc = parseInt('<% sysinfo("conn.wifi.2.assoc"); %>') + parseInt('<% sysinfo("conn.wifi.21.assoc"); %>') + parseInt('<% sysinfo("conn.wifi.22.assoc"); %>') + parseInt('<% sysinfo("conn.wifi.23.assoc"); %>');
	var conn_wifi_2g_autho = parseInt('<% sysinfo("conn.wifi.2.autho"); %>') + parseInt('<% sysinfo("conn.wifi.21.autho"); %>') + parseInt('<% sysinfo("conn.wifi.22.autho"); %>') + parseInt('<% sysinfo("conn.wifi.23.autho"); %>');
	var conn_wifi_2g_authe = parseInt('<% sysinfo("conn.wifi.2.authe"); %>') + parseInt('<% sysinfo("conn.wifi.21.authe"); %>') + parseInt('<% sysinfo("conn.wifi.22.authe"); %>') + parseInt('<% sysinfo("conn.wifi.23.authe"); %>');
	var conn_wifi_5g_assoc = parseInt('<% sysinfo("conn.wifi.5.assoc"); %>') + parseInt('<% sysinfo("conn.wifi.51.assoc"); %>') + parseInt('<% sysinfo("conn.wifi.52.assoc"); %>') + parseInt('<% sysinfo("conn.wifi.53.assoc"); %>');
	var conn_wifi_5g_autho = parseInt('<% sysinfo("conn.wifi.5.autho"); %>') + parseInt('<% sysinfo("conn.wifi.51.autho"); %>') + parseInt('<% sysinfo("conn.wifi.52.autho"); %>') + parseInt('<% sysinfo("conn.wifi.53.autho"); %>');
	var conn_wifi_5g_authe = parseInt('<% sysinfo("conn.wifi.5.authe"); %>') + parseInt('<% sysinfo("conn.wifi.51.authe"); %>') + parseInt('<% sysinfo("conn.wifi.52.authe"); %>') + parseInt('<% sysinfo("conn.wifi.53.authe"); %>');
	if (conn_wifi_2g_assoc >= 0)
		$("wifi2_clients_dt").innerHTML = "Associated:&nbsp;" + conn_wifi_2g_assoc + "&nbsp;&nbsp;-&nbsp;&nbsp;Authorized:&nbsp;" + conn_wifi_2g_autho + "&nbsp;&nbsp;-&nbsp;&nbsp;Authenticated:&nbsp;" + conn_wifi_2g_authe;
	else
		$("wifi2_clients_dt").innerHTML = "<i>Radio is off</i>";
	if (conn_wifi_5g_assoc >= 0)
		$("wifi5_clients_dt").innerHTML = "Associated:&nbsp;" + conn_wifi_5g_assoc + "&nbsp;&nbsp;-&nbsp;&nbsp;Authorized:&nbsp;" + conn_wifi_5g_autho + "&nbsp;&nbsp;-&nbsp;&nbsp;Authenticated:&nbsp;" + conn_wifi_5g_authe;
	else
		$("wifi5_clients_dt").innerHTML = "<i>Radio is off</i>";

if ((extendno == "") || (extendno == "0"))
		$("fwver").innerHTML = firmver + "." + buildno;
	else
		$("fwver").innerHTML =  firmver + "." + buildno + '_' + extendno.split("-g")[0];

	update_temperatures();
	nvram_state();
	hwaccel_state();
	show_etherstate();
}

function update_temperatures(){
	$j.ajax({
		url: '/ajax_coretmp.asp',
		dataType: 'script',
		error: function(xhr){
			update_temperatures();
		},
		success: function(response){
			code = "<b>2.4 GHz:</b><span> " + curr_coreTmp_2_raw + "</span>";
			if (band5g_support) {
				code += "&nbsp;&nbsp;-&nbsp;&nbsp;<b>5 GHz:</b> <span>" + curr_coreTmp_5_raw + "</span>";
			}
			if ((based_modelid == "RT-AC56U") || (based_modelid == "RT-AC68U")) {
				code +="&nbsp;&nbsp;-&nbsp;&nbsp;<b>CPU:</b> <span>" + curr_coreTmp_cpu +"&deg;C</span>";
			}
			$("temp_td").innerHTML = code;
			setTimeout("update_temperatures();", 3000);
		}
	});
}

function nvram_state(){
	var nvram_used = '<% sysinfo("nvram.used"); %>';
	var nvram_total = '<% sysinfo("nvram.total"); %>';
	var nvram_util = Math.floor(nvram_used/nvram_total*100);
	var code = nvram_used + ' / ' + nvram_total + ' bytes&nbsp;&nbsp;&nbsp;(' + nvram_util + '% utilized)';
	$("nvram_td").innerHTML = code;                                                                                 
}

function hwaccel_state(){
	if (hwacc == "1") {
		code = "Disabled";
		if (hwacc_force == "1")
			code += " <i>(by user)</i>";
		else {
			code += " <i> - incompatible with:<span>&nbsp;&nbsp;";	// Two trailing spaces
			if ('<% nvram_get("cstats_enable"); %>' == '1') code += 'IPTraffic, ';
			if ('<% nvram_get("qos_enable"); %>' == '1') code += 'QoS, ';
			if ('<% nvram_get("sw_mode"); %>' == '2') code += 'Repeater mode, ';
			if ('<% nvram_get("ctf_disable_modem"); %>' == '1') code += 'USB modem, ';

			// We're disabled but we don't know why
			if (code.slice(-6) == "&nbsp;") code += "&lt;unknown&gt;, ";

			// Trim two trailing chars ", "
			code = code.slice(0,-2) + "</span></i>";
		}
	} else if (hwacc == "0") {
		code = "<span>Enabled";
		if (ctf_fa != "") {
			if (ctf_fa == "2")
				code += " (CTF + FA)";
			else
				code += " (CTF only)";
		}
		code += "</span>";
	} else {
		code = "<span>N/A</span>";
	}

	$("hwaccel").innerHTML = code;
}


function showbootTime(){
        Days = Math.floor(boottime / (60*60*24));        
        Hours = Math.floor((boottime / 3600) % 24);
        Minutes = Math.floor(boottime % 3600 / 60);
        Seconds = Math.floor(boottime % 60);
        
        $("boot_days").innerHTML = Days;
        $("boot_hours").innerHTML = Hours;
        $("boot_minutes").innerHTML = Minutes;
        $("boot_seconds").innerHTML = Seconds;
        boottime += 1;
        setTimeout("showbootTime()", 1000);
}

function show_etherstate(){
	var state, state2;
	var hostname, devicename, devicemac, overlib_str, port;
	var tmpPort;
	var code = '<table cellpadding="0" cellspacing="0" width="100%"><tr><th style="width:15%;">Port</th><th style="width:15%;">VLAN</th><th style="width:25%;">Link State</th>';
	code += '<th style="width:45%;">Last Device Seen</th></tr>';

	var code_ports = "";
	var entry;

	var t = etherstate.split('>');

	for (var i = 0; i < t.length; ++i) {
		var line = t[i].split(/[\s]+/);

		if (line[11])
			devicemac = line[11].toUpperCase();
		else
			devicemac = "";

		if (line[0] == "Port") {
			if (line[2] == "DOWN")
				state2 = "Down";
			else {
				state = line[2].replace("FD"," Full Duplex");
				state2 = state.replace("HD"," Half Duplex");
			}

			hostname = "";

			if (devicemac == "00:00:00:00:00:00") {
				devicename = '<span class="ClientName">&lt;none&gt;</span>';
			} else {
				overlib_str = "<p><#MAC_Address#>:</p>" + devicemac;

				// Walk down arp cache and retrieve from hostname cache
				for (var j = 0; j < arplist.length; ++j) {
					if (arplist[j][3].toUpperCase() == devicemac) {
						hostname = hostnamecache[arplist[j][0]];
						break;
					}
				}

				if ((hostname != "") && (typeof hostname !== 'undefined')) {
					devicename = '<span class="ClientName" onclick="oui_query(\'' + devicemac +'\');;overlib_str_tmp=\''+ overlib_str +'\';return overlib(\''+ overlib_str +'\');" onmouseout="nd();" style="cursor:pointer; text-decoration:underline;">'+ hostname +'</span>';
				} else {
					devicename = '<span class="ClientName" onclick="oui_query(\'' + devicemac +'\');;overlib_str_tmp=\''+ overlib_str +'\';return overlib(\''+ overlib_str +'\');" onmouseout="nd();" style="cursor:pointer; text-decoration:underline;">'+ devicemac +'</span>'; 
				}
			}
			tmpPort = line[1].replace(":","");

			if (tmpPort == "8") {		// CPU Port
				break;
			} else if (based_modelid == "RT-AC56U") {
				tmpPort++;		// Port starts at 0
				if (tmpPort == "5") tmpPort = 0;	// Last port is WAN
			}                                                                                                                                                         
			if (tmpPort == "0") {
				port = "WAN";
			} else {
				if (based_modelid == "RT-N16") tmpPort = 5 - tmpPort;
				port = "LAN "+tmpPort;
			}
			entry = '<tr><td>' + port + '</td><td>' + (line[7] & 0xFFF) + '</td><td><span>' + state2 + '</span></td>';
			entry += '<td>'+ devicename +'</td></tr>';

			if (based_modelid == "RT-N16")
				code_ports = entry + code_ports;
			else
				code_ports += entry;
		}
	}
	code += code_ports + '</table>';
	$("etherstate_td").innerHTML = code;

	if (hostnamecache['ready'] == 0) setTimeout(show_etherstate, 500);
}

</script>
</head>

<body onload="initial();" onunLoad="return unload_body();">
<div id="TopBanner"></div>

<div id="Loading" class="popup_bg"></div>

<iframe name="hidden_frame" id="hidden_frame" src="" width="0" height="0" frameborder="0"></iframe>

<form method="post" name="form" id="ruleForm" action="/start_apply.htm" target="hidden_frame">
<input type="hidden" name="current_page" value="Tools_Sysinfo.asp">
<input type="hidden" name="next_page" value="Tools_Sysinfo.asp">
<input type="hidden" name="modified" value="0">
<input type="hidden" name="action_mode" value="apply">
<input type="hidden" name="action_script" value="">
<input type="hidden" name="action_wait" value="5">
<input type="hidden" name="first_time" value="">
<input type="hidden" name="SystemCmd" value="">
<input type="hidden" name="preferred_lang" id="preferred_lang" value="<% nvram_get("preferred_lang"); %>">
<input type="hidden" name="firmver" value="<% nvram_get("firmver"); %>">
<input type="hidden" name="ct_tcp_timeout" value="<% nvram_get("ct_tcp_timeout"); %>">
<input type="hidden" name="ct_udp_timeout" value="<% nvram_get("ct_udp_timeout"); %>">



<table class="content" align="center" cellpadding="0" cellspacing="0">
  <tr>
    <td width="17">&nbsp;</td>
    <td valign="top" width="202">
      <div id="mainMenu"></div>
      <div id="subMenu"></div></td>
    <td valign="top">
        <div id="tabMenu" class="submenuBlock"></div>

      <!--===================================Beginning of Main Content===========================================-->
      <table width="98%" border="0" align="left" cellpadding="0" cellspacing="0">
        <tr>
          <td valign="top">
            <table width="760px" border="0" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"  class="FormTitle" id="FormTitle">
                <tbody>
                <tr bgcolor="#4D595D">
                <td valign="top">
                <div>&nbsp;</div>
                <div class="formfonttitle">Tools - System Information</div>
                <div style="margin-left:5px;margin-top:10px;margin-bottom:10px"><img src="/images/New_ui/export/line_export.png"></div>

				<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"  class="FormTable">
					<thead>
						<tr>
							<td colspan="2">Router</td>
						</tr>
					</thead>
					<tr>
						<th>Model</th>
				        	<td id="model_id"><% nvram_get("productid"); %></td>
					</tr>
					<tr>
						<th>Firmware Version</th>
						<td id="fwver"></td>
					</tr>

					<tr>
						<th>Firmware Build</th>
						<td><% nvram_get("buildinfo"); %></td>
					</tr>
					<tr>
						<th>Bootloader (CFE)</th>
						<td><% sysinfo("cfe_version"); %></td>
					</tr>
					<tr>
						<th>Driver version</th>
						<td><% sysinfo("driver_version"); %></td>
					</tr>
					<tr>
						<th>Features</th>
						<td><% nvram_get("rc_support"); %></td>
					</tr>
					<tr>
						<th><#General_x_SystemUpTime_itemname#></a></th>
						<td><span id="boot_days"></span> <#Day#> <span id="boot_hours"></span> <#Hour#> <span id="boot_minutes"></span> <#Minute#> <span id="boot_seconds"></span> <#Second#></td>
					</tr>

					<tr>
						<th>Temperatures</th>
						<td id="temp_td"></td>
					</tr>
				</table>

				<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"  class="FormTable">
					<thead>
						<tr>
							<td colspan="2">CPU</td>
						</tr>
					</thead>

					<tr>
						<th>CPU Model</th>
						<td><% sysinfo("cpu.model"); %>	</td>
					</tr>
					<tr>
						<th>CPU Frequency</th>
						<td><% sysinfo("cpu.freq"); %> MHz</td>
					</tr>
					<tr>
						<th>CPU Load Average (1, 5, 15 mins)</th>
						<td>
							<% sysinfo("cpu.load.1"); %>,&nbsp;
							<% sysinfo("cpu.load.5"); %>,&nbsp;
							<% sysinfo("cpu.load.15"); %>
						</td>
					</tr>

				</table>

				<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3"  class="FormTable">
					<thead>
						<tr>
							<td colspan="2">Memory</td>
						</tr>
					</thead>
 					<tr>
						<th>Total</th>
						<td> <% sysinfo("memory.total"); %>&nbsp;MB</td>
					</tr>

					<tr>
						<th>Free</th>
						<td> <% sysinfo("memory.free"); %>&nbsp;MB</td>
					</tr>

 					<tr>
						<th>Buffers</th>
						<td> <% sysinfo("memory.buffer"); %>&nbsp;MB</td>
					</tr>

					<tr>
						<th>Swap usage</th>
						<td><% sysinfo("memory.swap.used"); %> / <% sysinfo("memory.swap.total"); %>&nbsp;MB</td>
					</tr>
				</table>

				<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0"bordercolor="#6b8fa3"  class="FormTable">
					<thead>
						<tr>
							<td colspan="2">Internal Storage</td>
						</tr>
					</thead>
					<tr>
						<th>NVRAM usage</th>
						<td id="nvram_td"></td>
					</tr>
					<tr>
						<th>JFFS</th>
						<td><% sysinfo("jffs.usage"); %></td>
					</tr>
				</table>

				<table width="100%" border="1" align="center" cellpadding="4" cellspacing="0"bordercolor="#6b8fa3"  class="FormTable">
					<thead>
						<tr>
							<td colspan="2">Network</td>
						</tr>
					</thead>
					<tr>
						<th>HW acceleration</th>
						<td id="hwaccel"></td>
					</tr>
					<tr>
						<th>Connections</th>
						<td><% sysinfo("conn.total"); %>&nbsp;/ <% sysinfo("conn.max"); %>&nbsp;&nbsp;-&nbsp;&nbsp;<% sysinfo("conn.active"); %> active</td>
					</tr>
					<tr>
						<th>Ethernet Ports</th>
						<td id="etherstate_td"><i><span>Querying switch...</span></i></td>
					</tr>
					<tr id="wifi2_clients_tr">
						<th>Wireless clients (2.4 GHz)</th>
						<td id="wifi2_clients_dt"></td>
					</tr>
					<tr id="wifi5_clients_tr">
						<th>Wireless clients (5 GHz)</th>
						<td id="wifi5_clients_dt"></td>
					</tr>
				</table>
				</td>
				</tr>

				<tr class="apply_gen" valign="top" height="95px">
					<td>
						<input type="button" onClick="location.href=location.href" value="<#CTL_refresh#>" class="button_gen">
					</td>
				</tr>
	        </tbody>
            </table>
            </form>
            </td>

       </tr>
      </table>
      <!--===================================Ending of Main Content===========================================-->
    </td>
    <td width="10" align="center" valign="top">&nbsp;</td>
  </tr>
</table>
<div id="footer"></div>
</body>
</html>

