<?php

$mageFilename = 'app/Mage.php';

require_once $mageFilename;

umask(0);
Mage::app('admin');

Mage::app()->cleanAllSessions();
Mage::app()->getCacheInstance()->flush();
Mage::app()->cleanCache();

$types = Mage::app()->getCacheInstance()->getTypes();
$allTypes = Mage::app()->useCache();

$allTypes['full_page'] = 1;
$tags = Mage::app()->getCacheInstance()->cleanType('full_page');
Mage::app()->saveUseCache($allTypes);
