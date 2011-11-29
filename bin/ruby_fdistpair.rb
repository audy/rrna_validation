require 'savon'
require 'cgi'

WSDL_URL = 'http://www.ebi.ac.uk/soaplab/typed/services/phylogeny_consensus.ftreedistpair?wsdl'



client = Savon::Client.new do
  wsdl.document = WSDL_URL
end

p client.wsdl.soap_actions


response = client.request('runAndWaitFor',
  'style_s' => 'true',
  'intreefile_direct_data' => File.read('intree'),
  'bintreefile_direct_data' => File.read('intree')
)

