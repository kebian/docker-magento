<?php
$http_host = ($_SERVER['HTTP_HOST']);
$user = 'root';
$pass = 'pass';
$prefix = '';

$vars = [
	'web/unsecure/base_url' => $http_host,
	'web/secure/base_url' => $http_host,
];

mysql_connect('db',$user, $pass) or die ('mysql error');
mysql_select_db('magento');

foreach($vars as $name => $val) {
	mysql_query("update {$prefix}core_config_data set value='$val' where path='$name'");
}

echo "host set to : $http_host";

system("rm -Rf var/cache/mage*");