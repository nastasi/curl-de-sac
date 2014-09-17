<?php

$query_ip  = $_POST['QueryIP'];
$dest_ip   = $_POST['DestinationIP'];
$dest_port = $_POST['DestinationPort'];

printf("QUERY_IP: [%s]\n", $query_ip);

if ($query_ip == "178.162.193.213") {
    // <td class="TRC"><br><br><b><font color="#00dd00">-The IP Address you entered matches one or more active Tor servers-</font><br><br>Server name: <a class="plain" href="http://torstatus.blutmagie.de/router_detail.php?FP=89e3170b4e2fc9a430fb97536769fc0abf6c4db3">hviv103</a><br><br></b></td>

    readfile("Data/tor_mock_ok.html");
}
else if ($query_ip == "178.162.193.214") {
    echo "NOTHING NOTHING!";
}
else {
    readfile("Data/tor_mock_bad.html");
}
?>
