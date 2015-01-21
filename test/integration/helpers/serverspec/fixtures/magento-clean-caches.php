<?php

$mageFilename = 'app/Mage.php';

require_once $mageFilename;

umask(0);
Mage::app('admin');

try {
  Mage::app()->cleanAllSessions();
  Mage::app()->getCacheInstance()->flush();
  Mage::app()->cleanCache();

  $allTypes = Mage::app()->useCache();
  foreach($allTypes as $type => $blah) {
    Mage::app()->getCacheInstance()->cleanType($type);
  }
} catch (Exception $e) {
  // do something
  error_log($e->getMessage());
}

# make this last in case we aren't using EE, it will error (but ok)
try {
  # UI fires this event, but cmdline doesn't
  Enterprise_PageCache_Model_Cache::getCacheInstance() ->clean(Enterprise_PageCache_Model_Processor::CACHE_TAG);
} catch (Exception $e) {} # eat silently

echo "Caches flushed\n";
