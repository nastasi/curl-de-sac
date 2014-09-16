#!/usr/bin/php
<?php

define('WEB_URL', 'http://localhost/curl-de-sac');
define('TOR_CHK_URL', 'http://localhost/curl-de-sac/test/tor_mock.php');
define('DBG_LEVEL', 0);

$G_base = "./";

require_once($G_base . 'Obj/curl-de-sac.phh');
require_once($G_base . 'Obj/curl-de-brisk.phh');

class Brisk_mock {
    function cds_postprocess($user_idx, $user_sess, $conn_ip, $is_tor)
    {
        printf("user_idx: %d, user_sess: %s, conn_ip: %s, is_tor: %s\n",
               $user_idx, $user_sess, $conn_ip, ($is_tor ? "YES" : "NO"));
    }
}

function main()
{
    $brisk = new Brisk_mock();
    $debug = DBG_LEVEL;
    // create cds
    $cds = new Curl_de_sac($debug);

    // create tor_chk_cls
    $tor_chk_cls = new tor_chk_cmd_cls();

    // registrer tor_chk_cls
    printf("MAIN: Register 'tor_chk_cls'\n");
    if (($cds->cmd_cls_register($tor_chk_cls)) == FALSE) {
        fprintf(STDERR, "MAIN: 'tor_chk_cls' registration failed\n");
        exit(1);
    }

    if (($debug & 1) == 1) {
        printf("MAIN: CDS:\n");
        print_r($cds);
        printf("\n");
    }

    // for ($i = -15 ; $i < 30 ; $i++) {
    for ($i = 0 ; $i < 10 ; $i++) {
        printf("MAIN: START ITERATION %d\n", $i);

         if ($i == 2) {
             // Case OK
            printf("MAIN: load 'tor_chk'\n");
            if ($cds->execute("tor_chk", $brisk, 24, "caffe", "178.162.193.213") == FALSE) {
                printf("MAIN: push 'tor_chk' command failed\n");
                exit(123);
            }
         }

         else if ($i == 4) {
             // Case Malformed output
            printf("MAIN: load 'tor_chk'\n");
            if ($cds->execute("tor_chk", $brisk, 24, "caffe", "178.162.193.214") == FALSE) {
                printf("MAIN: push 'tor_chk' command failed\n");
                exit(123);
            }
         }
         else if ($i == 6) {
             // Case NO
            printf("MAIN: load 'tor_chk'\n");
            if ($cds->execute("tor_chk", $brisk, 24, "caffe", "178.162.193.215") == FALSE) {
                printf("MAIN: push 'tor_chk' command failed\n");
                exit(123);
            }
        }

        printf("MAIN:");
        if (($debug & 1) == 1) {
            printf(" CDS:\n");
            print_r($cds);
            printf("\n");
        }

        printf("MAIN: Call process\n");
        $cds->process();
        sleep(1);
    }
    printf("MAIN: finished, dump cds:\n");
    print_r($cds);
    // start loop
    //   print status
    //   if input data execute some command
    //   if end => clean exit
    exit(0);
}

main();

?>