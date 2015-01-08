<?php
if (version_compare(phpversion(), '5.2.0', '<')===true) {
  die('ERROR: Whoops, it looks like you have an invalid PHP version. Magento supports PHP 5.2.0 or newer.');
}
set_include_path(dirname(__FILE__) . PATH_SEPARATOR . get_include_path());
require 'app/Mage.php';

try {
  $app = Mage::app('default');

  $installer = Mage::getSingleton('install/installer_console');
  /* @var $installer Mage_Install_Model_Installer_Console */

  if ($installer->init($app))
  {
    echo "SUCCESS: Did not find any installation of Magento\n";
    exit(0);
  }

} catch (Exception $e) {
  echo "FATAL:\n";
  Mage::printException($e);
  exit(2);
}

// print all errors if there were any
if ($installer instanceof Mage_Install_Model_Installer_Console) {
  if ($installer->getErrors()) {
    foreach ($installer->getErrors() as $error) {
      echo "FAILED: " . $error . "\n";
    }
  }
}
exit(1); // don't delete this as this should notify about failed installation
