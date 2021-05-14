duckdns isa ontology ~ https://www.duckdns.org/ns/duckdns/

duckdns:update isa ts:function
               isa ts:side-effect
return """
   my $token     = $_[0]->[0];
   my $subdomain = $_[1]->[0];
# warn "token $token subdomain $subdomain";
   $TM2::log->logdie( "access token not defined" ) unless defined $token;
# warn "ctx ".TM2::TempleScript::PE::ctx_dump ($ctx);
   my $loop = TM2::TempleScript::PE::lookup_var( $ctx, '$loop' );
# warn "ctx $ctx loop $loop";
   use Net::Async::HTTP;
   my $http = Net::Async::HTTP->new();
   $loop->add( $http );

   my $resp = $http->GET( "https://www.duckdns.org/update?domains=$subdomain&token=$token&verbose=true" )->get;
# use Data::Dumper;
# warn Dumper $resp;
   if ($resp->is_success) {  # this does not mean anything
       if ($resp->content =~ /^OK/) {
           return [ TM2::Literal->new( $resp->content ) ];
       } else { # KO, or else
           $TM2::log->logdie( "duckdns:update: ".$resp->content );
       }
   } else {
       $TM2::log->logdie( "duckdns:update: ".$resp->message );
   }
""" ^^ lang:perl !

