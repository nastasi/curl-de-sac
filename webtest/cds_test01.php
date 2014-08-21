require_once('Obj/curl-de-sac.phh');

class short_cmd_cls extends CDS_cmd_cls {
    function short_cmd_cls() 
    {
        parent::__construct("short", 10);
    }

    function cb()
    {
        printf("short_cb:\n");
    }
}

class long_cmd_cls extends CDS_cmd_cls {
    function long_cmd_cls() 
    {
        parent::__construct("long", 15);
    }

    function cb()
    {
        printf("long_cb:\n");
    }
}

function main()
{
    // create cds
    $cds = new Curl_de_sac();

    // create cds_cmd 1
    $cmd_cls1 = new short_cmd_cls();

    // registrer cds_cmd 1
    if (($cds->cmd_register($cmd_cls1)) == FALSE) {
        fprintf(STDERR, "cmd_cls1 registration failed\n");
        exit(1);
    }

    // create cds_cmd 2
    $cmd_cls2 = new long_cmd_cls();

    // register cds_cmd 2
    if (($cds->cmd_register($cmd_cls2)) == FALSE) {
        fprintf(STDERR, "cmd_cls2 registration failed\n");
        exit(2);
    }

    // register cds_cmd 2 (retry)
    if (($cds->cmd_register($cmd_cls2)) != FALSE) {
        fprintf(STDERR, "cmd_cls2 re-registration success\n");
        exit(3);
    }

    // start loop
    //   print status
    //   if input data execute some command
    //   if end => clean exit
    exit(0);
}

main();

?>