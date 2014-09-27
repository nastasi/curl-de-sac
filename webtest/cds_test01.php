#!/usr/bin/php
<?php

define('WEB_URL', 'http://localhost/curl-de-sac');
define('DBG_LEVEL', 0);

$G_base = "./";

require_once($G_base . 'Obj/curl-de-sac.phh');

class short_cmd extends CDS_cmd {
    var $short_data;

    function short_cmd($cmd_cls, $ch, $short_data)
    {
        parent::__construct($cmd_cls, $ch);
        $this->short_data = $short_data;
    }
}

class short_cmd_cls extends CDS_cmd_cls {
    function short_cmd_cls()
    {
        parent::__construct("short", 10);
    }

    function create($cds, $url)
    {
        if ($cds->dbg_get() > 0) {
            printf("'short'::create url:[%s]\n", $url);
        }

        do {
            if (($ch = parent::pre_create($cds, $url)) == FALSE)
                break;

            if (parent::create($cds, $ch) == FALSE)
                break;

            $cmd = new short_cmd($this, $ch, "none currently");

            return $cmd;
        } while (FALSE);
        
        return FALSE;
    }

    function process($cmd, $ret)
    {
        if ($this->dbg_get() > 2) { printf("CURL: 'short' process: curl_multi_getcontent\n"); }

        $content = curl_multi_getcontent($cmd->ch_get());
        if ($this->dbg_get() > 0) { printf("'short' process: [%s]\n", $content); }

        return TRUE;
    }

    function timeout($cmd)
    {
        printf("'Short' timeout function reached\n");
    }
}

class long_cmd extends CDS_cmd {
    var $long_data;

    function long_cmd($cmd_cls, $ch, $long_data)
    {
        parent::__construct($cmd_cls, $ch);
        $this->long_data = $long_data;
    }
}

class long_cmd_cls extends CDS_cmd_cls {
    function long_cmd_cls()
    {
        parent::__construct("long", 5);
    }

    function create($cds, $url)
    {
        if ($cds->dbg_get() > 0) {
            printf("'long'::create url:[%s]\n", $url);
        }

        do {
            if (($ch = parent::pre_create($cds, $url)) == FALSE)
                break;

            if (parent::create($cds, $ch) == FALSE)
                break;

            $cmd = new long_cmd($this, $ch, "none currently");

            return $cmd;
        } while (FALSE);
        
        return FALSE;
    }

    function process($cmd, $ret)
    {
        if ($this->dbg_get() > 2) { printf("CURL: 'long' process: curl_multi_getcontent\n"); }

        $content = curl_multi_getcontent($cmd->ch_get());
        if ($this->dbg_get() > 0) { printf("'long' process: [%s]\n", $content); }

        return TRUE;
    }

    function timeout($cmd)
    {
        printf("'Long' timeout function reached\n");
    }
}


function main()
{
    $debug = DBG_LEVEL;
    // create cds
    $cds = new Curl_de_sac($debug);

    // create short_cls
    $short_cls = new short_cmd_cls();

    // registrer short_cls
    printf("MAIN: Register 'short_cls'\n");
    if (($cds->cmd_cls_register($short_cls)) == FALSE) {
        fprintf(STDERR, "MAIN: 'short_cls' registration failed\n");
        exit(1);
    }

    // create long_cls
    $long_cls = new long_cmd_cls();

    // register long_cls
    printf("MAIN: Register 'long_cls'\n");
    if (($cds->cmd_cls_register($long_cls)) == FALSE) {
        fprintf(STDERR, "MAIN: 'long_cls' registration failed\n");
        exit(2);
    }

    // register long_cls (retry)
    printf("MAIN: Re-register 'long_cls' (must go wrong)\n");
    if (($cds->cmd_cls_register($long_cls)) != FALSE) {
        fprintf(STDERR, "MAIN: 'long_cls' re-registration success\n");
        exit(3);
    }

    printf("MAIN: CDS:\n");
    if (($debug & 1) == 1)
        print_r($cds);
    printf("MAIN: Deregister 'long_cls'\n");
    if (($cds->cmd_cls_deregister($long_cls)) == FALSE) {
        fprintf(STDERR, "MAIN: 'long_cls' deregistration failed\n");
        exit(4);
    }
    printf("MAIN:");
    if (($debug & 1) == 1) {
        printf(" CDS:\n");
        print_r($cds);
    }
    printf("\n");
    // re-re-register long_cls
    printf("MAIN: Re-re-register 'long_cls'\n");
    if (($cds->cmd_cls_register($long_cls)) == FALSE) {
        fprintf(STDERR, "MAIN: 'long_cls' re-re-registration failed\n");
        exit(5);
    }

    printf("MAIN: Deregister all\n");
    $cds->cmd_cls_deregister_all();

    // registrer short_cls
    printf("MAIN: register 'short_cls'\n");
    if (($cds->cmd_cls_register($short_cls, 10)) == FALSE) {
        fprintf(STDERR, "MAIN: 'short_cls' registration failed\n");
        exit(1);
    }

    // register long_cls
    printf("MAIN: register 'long_cls'\n");
    if (($cds->cmd_cls_register($long_cls, 4)) == FALSE) {
        fprintf(STDERR, "MAIN: 'long_cls' registration failed\n");
        exit(2);
    }
    printf("MAIN:");
    if (($debug & 1) == 1) {
        printf(" CDS:\n");
        print_r($cds);
    }
    printf("\n");

    // for ($i = -15 ; $i < 30 ; $i++) {
    for ($i = 0 ; $i < 20 ; $i++) {
        printf("MAIN: START ITERATION %d\n", $i);

         if ($i == 2) {
            printf("MAIN: load 'short'\n");
            if ($cds->execute("short", WEB_URL.'/test/short.php') == FALSE) {
                printf("MAIN: push 'short' command failed\n");
                exit(123);
            }
        }

         if ($i == 3) {
            printf("MAIN: load 'short'\n");
            if ($cds->execute("short", WEB_URL.'/test/short.php') == FALSE) {
                printf("MAIN: push 'short' command failed\n");
                exit(123);
            }
        }

        if ($i == 4) {
            printf("MAIN: load 'long'\n");
            if ($cds->execute("long", WEB_URL.'/test/long.php') == FALSE) {
                printf("MAIN: push 'long' command failed\n");
                exit(123);
            }
        }

        printf("MAIN:");
        if (($debug & 1) == 1) {
            printf(" CDS:\n");
            print_r($cds);
        }
        printf("\n");

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