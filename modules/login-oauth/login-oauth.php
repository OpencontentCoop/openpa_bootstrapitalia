<?php

use League\OAuth2\Client\Provider\GenericProvider;

/** @var eZModule $Module */
$Module = $Params['Module'];
$Module->setExitStatus(eZModule::STATUS_IDLE);
$http = eZHTTPTool::instance();

function flatArrayKeys($array, $prefix = '')
{
    $result = [];
    foreach ($array as $key => $value) {
        if (is_array($value)) {
            $result = $result + flatArrayKeys($value, $prefix . strtolower($key) . '_');
        } else {
            $result[$prefix . strtolower($key)] = $value;
        }
    }
    return $result;
}

$ini = eZINI::instance();
$redirectionURI = '/';

try {

    if (!BootstrapItaliaLoginOauth::instance()->isEnabled()){
        throw new RuntimeException('Oauth feature is disabled');
    }

    $createUserIfNeeded = BootstrapItaliaLoginOauth::instance()->canCreateUserIfNeeded();
    $attributesMap = BootstrapItaliaLoginOauth::instance()->getAttributesMap();
    $allowedEmailList = BootstrapItaliaLoginOauth::instance()->getAllowedEmailList();
    $provider = new GenericProvider(BootstrapItaliaLoginOauth::instance()->getProviderSettings());

    if (!isset($_GET['code'])) {
        $authorizationUrl = $provider->getAuthorizationUrl();
        $_SESSION['oauth2state'] = $provider->getState();
        header('Location: ' . $authorizationUrl);
        eZExecution::cleanExit();
    } elseif (empty($_GET['state']) || (isset($_SESSION['oauth2state']) && $_GET['state'] !== $_SESSION['oauth2state'])) {
        if (isset($_SESSION['oauth2state'])) {
            unset($_SESSION['oauth2state']);
        }
        throw new Exception('Invalid oauth state');
    }
    $accessToken = $provider->getAccessToken('authorization_code', [
        'code' => $_GET['code'],
    ]);
    $_SESSION['token'] = json_encode($accessToken);
    $resourceOwner = $provider->getResourceOwner($accessToken);
    $user = flatArrayKeys($resourceOwner->toArray());

    $login = $user[$attributesMap['login']] ?? null;
    $email = $user[$attributesMap['email']] ?? null;
    $firstName = $user[$attributesMap['first_name']] ?? $login;
    $lastName = $user[$attributesMap['last_name']] ?? $login;

    if (!$email && !$login) {
        throw new RuntimeException('Unable to find login and email in data ' . var_export($user, true));
    }

    $email = strtolower($email);
    if (!empty($allowedEmailList) && !in_array($email, $allowedEmailList)) {
        throw new RuntimeException('User can not login with oauth ' . $email);
    }

    $user = eZUser::fetchByName($login) ?? eZUser::fetchByEmail($email);
    if (!$user instanceof eZUser) {
        if (!$createUserIfNeeded) {
            throw new RuntimeException('User not found');
        } else {
            $params = [];
            $params['creator_id'] = (int)$ini->variable("UserSettings", "UserCreatorID");
            $params['class_identifier'] = 'user';
            $params['parent_node_id'] = (int)$ini->variable("UserSettings", "DefaultUserPlacement");
            $params['attributes'] = [
                'first_name' => $firstName,
                'last_name' => $lastName,
                'user_account' => $login . '|' . $email . '||' .
                    eZUser::passwordHashTypeName(eZUser::hashType()) . '|1',
            ];
            $userObject = eZContentFunctions::createAndPublishObject($params);
            if (!$userObject instanceof eZContentObject) {
                throw new RuntimeException('Unable to create user with data ' . var_export($params, true));
            }
            $user = eZUser::fetch((int)$userObject->attribute('id'));
        }
    }

    eZAudit::writeAudit(
        'user-login',
        ['Provider' => 'oauth', 'User id' => $user->id(), 'User login' => $user->attribute('login')]
    );

    eZUser::updateLastVisit($user->id(), true);
    eZUser::setCurrentlyLoggedInUser($user, $user->id());
    eZUser::setFailedLoginAttempts($user->id(), 0);
    eZHTTPTool::instance()->setSessionVariable(BootstrapItaliaLoginOauth::CURRENT_SESSION_VARNAME, true);
} catch (Exception $e) {
    eZDebug::writeError($e->getMessage(), __FILE__);
    return $Module->handleError(eZError::KERNEL_ACCESS_DENIED, 'kernel', ['error' => $e->getMessage()]);
}

header('Location: ' . $redirectionURI);
eZExecution::cleanExit();