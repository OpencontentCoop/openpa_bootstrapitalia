<?php

class BootstrapItaliaPdf
{
    private $wkhtmltopdfUrl;

    private $templateUri;

    private $object;

    /**
     * @var array
     */
    private $templateVariables;

    /**
     * @var string
     */
    private $filename;

    public function __construct(
        eZContentObject $object,
        string $templateUri,
        string $filename,
        array $templateVariables = []
    ) {
        $this->wkhtmltopdfUrl = OpenPAINI::variable('PdfSettings', 'WkHtmlToPdfUri');
        $this->object = $object;
        $this->templateUri = $templateUri;
        $this->templateVariables = $templateVariables;
        $this->filename = $filename;
    }

    private function hasValidUrl()
    {
        return !empty($this->wkhtmltopdfUrl);
    }

    public function generateHtml()
    {
        $tpl = eZTemplate::factory();
        $tpl->setVariable('object', $this->object);
        foreach ($this->templateVariables as $key => $value) {
            $tpl->setVariable($key, $value);
        }
        return $tpl->fetch($this->templateUri);
    }

    public function generatePdf(
        $options = [
            'page-width' => '210mm',
            'page-height' => '296mm',
            'margin-top' => '1mm',
            'margin-left' => '1mm',
            'margin-right' => '1mm',
            'margin-bottom' => '1mm',
            'encoding' => 'UTF-8',
        ]
    ) {
        if (!$this->hasValidUrl()) {
            throw new RuntimeException('Invalid WkHtmlToPdf uri');
        }

        $ch = curl_init();
        curl_setopt($ch, CURLOPT_URL, $this->wkhtmltopdfUrl);
        curl_setopt($ch, CURLOPT_HTTPHEADER, ['Content-type: application/json']);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
        $body = json_encode([
            'contents' => base64_encode(trim($this->generateHtml())),
            'options' => $options,
            'header' => base64_encode('<!DOCTYPE html></html>'),
            'footer' => base64_encode('<!DOCTYPE html></html>'),
        ]);
        curl_setopt($ch, CURLOPT_POSTFIELDS, $body);
        $data = curl_exec($ch);
        $error = curl_errno($ch);
        $info = curl_getinfo($ch);
        if ($info['http_code'] != 200) {
            $error = $data;
        }
        if ($error) {
            throw new RuntimeException('Unable to generate pdf: ' . $error);
        }

        return $data;
    }

    public function handleDownload($disposition = 'attachment')
    {
        $data = $this->generatePdf();
        $size = strlen($data);
        ob_clean();
        header("Pragma: ");
        header("Cache-Control: ");
        header("Last-Modified: ");
        header("Expires: " . gmdate('D, d M Y H:i:s', time() + 1) . ' GMT');
        header('Content-Type: application/pdf');
        header('Content-Disposition: ' . $disposition . '; filename="' . $this->filename . '"');
        header('Content-Length: ' . $size);
        header('Content-Transfer-Encoding: binary');
        header('Accept-Ranges: bytes');
        ob_end_clean();
        echo $data;
        eZExecution::cleanExit();
    }
}