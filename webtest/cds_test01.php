#!/usr/bin/php
<?php

define('WEBURL', 'http://localhost/curl-de-sac');

require_once('Obj/curl-de-sac.phh');

class short_cmd extends CDS_cmd {
    var $short_data;

    function short_cmd($ch, $cmd_cls, $short_data)
    {
        parent::__construct($ch, $cmd_cls);
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
        printf("short::create url:[%s]\n", $url);
        
        do {
            if (($ch = parent::pre_create($url)) == FALSE)
                break;

            if (parent::create($cds, $ch) == FALSE)
                break;

            $cmd = new short_cmd($ch, $this, "none currently");

            return $cmd;
        } while (FALSE);
        
        return FALSE;
    }

    function cb()
    {
        printf("short_cb:\n");
    }
}

class long_cmd extends CDS_cmd {
    var $long_data;

    function long_cmd($ch, $cmd_cls, $long_data)
    {
        parent::__construct($ch, $cmd_cls);
        $this->long_data = $long_data;
    }
}

class long_cmd_cls extends CDS_cmd_cls {
    function long_cmd_cls()
    {
        parent::__construct("long", 10);
    }

    function create($cds, $url)
    {
        printf("long::create url:[%s]\n", $url);
        
        do {
            if (($ch = parent::pre_create($url)) == FALSE)
                break;

            if (parent::create($cds, $ch) == FALSE)
                break;

            $cmd = new long_cmd($ch, $this, "none currently");

            return $cmd;
        } while (FALSE);
        
        return FALSE;
    }

    function cb()
    {
        printf("long_cb:\n");
    }
}


function main()
{
    // create cds
    $cds = new Curl_de_sac(999);

    // create cds_cmd 1
    $cmd_cls1 = new short_cmd_cls();

    // registrer cds_cmd 1
    printf("Register CLS1\n");
    if (($cds->cmd_register($cmd_cls1)) == FALSE) {
        fprintf(STDERR, "cmd_cls1 registration failed\n");
        exit(1);
    }

    // create cds_cmd 2
    $cmd_cls2 = new long_cmd_cls();

    // register cds_cmd 2
    printf("Register CLS2\n");
    if (($cds->cmd_register($cmd_cls2)) == FALSE) {
        fprintf(STDERR, "cmd_cls2 registration failed\n");
        exit(2);
    }

    // register cds_cmd 2 (retry)
    printf("Re-register CLS2 (must go wrong)\n");
    if (($cds->cmd_register($cmd_cls2)) != FALSE) {
        fprintf(STDERR, "cmd_cls2 re-registration success\n");
        exit(3);
    }

    print_r($cds);
    printf("Deregister CLS2\n");
    if (($cds->cmd_deregister($cmd_cls2)) == FALSE) {
        fprintf(STDERR, "cmd_cls2 deregistration failed\n");
        exit(4);
    }
    print_r($cds);

    // re-re-register cds_cmd 2
    printf("Re-re-register CLS2\n");
    if (($cds->cmd_register($cmd_cls2)) == FALSE) {
        fprintf(STDERR, "cmd_cls2 re-re-registration failed\n");
        exit(5);
    }

    printf("Deregister all\n");
    $cds->cmd_deregister_all();

    // registrer cds_cmd 1
    printf("Register CLS1\n");
    if (($cds->cmd_register($cmd_cls1)) == FALSE) {
        fprintf(STDERR, "cmd_cls1 registration failed\n");
        exit(1);
    }

    // register cds_cmd 2
    printf("Register CLS2\n");
    if (($cds->cmd_register($cmd_cls2)) == FALSE) {
        fprintf(STDERR, "cmd_cls2 registration failed\n");
        exit(2);
    }
    print_r($cds);
    printf("SUCCESS\n");

    for ($i = 0 ; $i < 10 ; $i++) {
        if ($i == 2) {
            print("load short\n");
            if ($cds->execute("short", WEBURL.'/short.php') == FALSE) {
                printf("push command failed\n");
                exit(123);
            }
        }
        printf("Call process\n");
        $cds->process();
        sleep(1);
    }
    // start loop
    //   print status
    //   if input data execute some command
    //   if end => clean exit
    exit(0);
}

main();

?>