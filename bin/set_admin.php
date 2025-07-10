<?php

require 'autoload.php';

$script = eZScript::instance([
    'description' => ("Rock and roll\n\n"),
    'use-session' => false,
    'use-modules' => true,
    'use-extensions' => true,
]);

$script->startup();

$options = $script->getOptions('[mail:][password:]');
$script->initialize();
$script->setUseDebugAccumulators(true);
$cli = eZCLI::instance();

$newMail = $options['mail'] ?? null;
$newPassword = $options['password'] ?? null;

$admin = eZUser::fetchByName('admin');
if ($admin instanceof eZUser) {

    if ($newMail && $admin->attribute('email') !== $newMail) {
        $cli->warning('Set admin email to ' . $newMail);
        $admin->setAttribute('email', $newMail);
        $admin->store();
    }

    if ($newPassword) {
        $cli->warning('Reset password');
        $paEx = eZPaEx::getPaEx($admin->id());
        if ($paEx instanceof eZPaEx) {
            $passwordLastUpdated = 0;
            $expirationNotificationSent = 0;
            $cli->warning('Reset password lat update');
            $paEx->setAttribute('password_last_updated', $passwordLastUpdated);
            $paEx->setAttribute('expirationnotification_sent', $expirationNotificationSent);
        }
        eZAudit::writeAudit(
            'user-password-change',
            [
                'User id' => $admin->attribute('contentobject_id'),
                'User login' => $admin->attribute('login'),
                'Force reset from script' => 1,
            ]
        );
        $cli->warning('Set admin password to ' . $newPassword);
        eZUserOperationCollection::password($admin->id(), $newPassword);
    }

    $cli->output('Reset failed login count');
    eZUser::setFailedLoginAttempts($admin->attribute('contentobject_id'), 0);
}

$script->shutdown();
