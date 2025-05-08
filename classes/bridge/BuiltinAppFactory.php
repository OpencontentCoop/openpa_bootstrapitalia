<?php

class BuiltinAppFactory
{
    public static function instanceByIdentifier(string $identifier): BuiltinApp
    {
        if ($identifier === 'support'){
            $identifier = 'helpdesk_v1';
            if (BuiltinApp::getCurrentOptions('EnableHelpdeskV2')){
                $identifier = 'helpdesk_v2';
            }
        }
        switch ($identifier) {
            case 'booking':
                $app = new BookingBuiltinApp();
                break;
            case 'helpdesk_v1':
                $app = new HelpdeskBuiltinApp();
                break;
            case 'helpdesk_v2':
                    $app = new HelpdeskV2BuiltinApp();
                break;
            case 'inefficiency':
                $app = new InefficiencyBuiltinApp();
                break;
            case 'service-form':
                $app = new ServiceFormBuiltinApp('Fill out the form');
                break;
            case 'payment':
                $app = new PaymentBuiltinApp();
                break;
            case 'login':
                $app = new LoginBoxBuiltinApp();
                break;
            case 'personal-area':
                $app = new PersonalAreaBuiltinApp();
                break;
            case 'payments-area':
                $app = new PaymentsAreaBuiltinApp();
                break;
            case 'documents-area':
                $app = new DocumentsAreaBuiltinApp();
                break;
            default:
                throw new InvalidArgumentException("Unknown builtin identifier $identifier");
        }

        return $app;
    }

    public static function fetchDescriptionIdentifierList(): array
    {
        return [
            'booking',
            'inefficiency',
            'payment',
            'helpdesk_v1',
            'helpdesk_v2',
            'service-form',
            'personal-area',
            'payments-area',
            'documents-area',
        ];
    }
}