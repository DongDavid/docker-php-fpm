#!/usr/bin/php
<?php

/**
 * This script is a sendmail wrapper for php to log calls of the php mail() function.
 * Author: Till Brehm, www.ispconfig.org
 * (Hopefully) secured by David Goodwin <david @ _palepurple_.co.uk>
 * https://www.howtoforge.com/how-to-log-emails-sent-with-phps-mail-function-to-detect-form-spam
 */

$sendmail_bin = '/usr/sbin/sendmail';

// Get the email content
$mail    = '';
$logline = '';
$pointer = fopen('php://stdin', 'r');

while ($line = fgets($pointer)) {
    if (preg_match('/^to:/i', $line) || preg_match('/^from:/i', $line)) {
        $logline .= trim($line) . ' ';
    }
    $mail .= $line;
}

// Compose the sendmail command
$command = 'echo ' . escapeshellarg($mail) . ' | ' . $sendmail_bin . ' -t -i';

if (isset($_SERVER['argc'])) {
	for ($i = 1; $i < $_SERVER['argc']; $i++) {
	    $command .= escapeshellarg($_SERVER['argv'][$i]) . ' ';
	}
}

// Write the log
$stdout = fopen('php://stdout', 'w');
fwrite($stdout, (isset($_ENV['USER']) ? $_ENV['USER'] . ' ' : '') . $logline . ' - ' . $command . "\n");

// Execute the command
return shell_exec($command);
