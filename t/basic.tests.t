use MarpaX::Demo::JSONParser;

use Test::More;
use Test::Exception;

use Try::Tiny;

# ------------------------------------------------

sub run_test
{
	my($user_bnf, $string) = @_;

	# Try, but don't bother to catch. Just return undef.

	my($result);

	# Use try to catch die.

	try
	{
		$result = MarpaX::Demo::JSONParser -> new(user_bnf_file => $user_bnf) -> parse($string);
	};

	return $result;

} # End of run_test.

# ------------------------------------------------

sub run_tests
{
	my($user_bnf) = @_;

	$data = run_test($user_bnf, '{[}');
	is($data, undef, 'Expect parse to die');

	$data = run_test($user_bnf, '{"["}');
	is($data, undef, 'Expect parse to die');

	$data = run_test($user_bnf, '{[[}');
	is($data, undef, 'Expect parse to die');

	$data = run_test($user_bnf, '{"[["}');
	is($data, undef, 'Expect parse to die');

	$data = run_test($user_bnf, '{');
	is($data, undef, 'Expect parse to die');

	$data = run_test($user_bnf, '"a');
	is($data, undef, 'Expect parse to die');

	my $data = run_test($user_bnf, '{"test":"1"}');
	is($$data{test}, 1, 'Expect parse to succeed');

	$data = run_test($user_bnf, '{"test":[1,2,3]}');
	is_deeply($$data{test}, [1,2,3], 'Expect parse to succeed');

	$data = run_test($user_bnf, '{"test":true}');
	is($$data{test}, 1, 'Expect parse to succeed');

	$data = run_test($user_bnf, '{"test":false}');
	is($$data{test}, '', 'Expect parse to succeed');

	$data = run_test($user_bnf, '{"test":null}');
	is($$data{test}, undef, 'Expect parse to succeed');

	$data = run_test($user_bnf, '{"test":null, "test2":"hello world"}');
	is($$data{test}, undef, 'Expect parse to succeed');
	is($data->{test2}, "hello world", 'Expect parse to succeed');

	$data = run_test($user_bnf, '{"test":"1.25"}');
	is($$data{test}, '1.25', 'Expect parse to succeed');

	$data = run_test($user_bnf, '{"test":"1.25e4"}');
	is($$data{test}, '1.25e4', 'Expect parse to succeed');

	$data = run_test($user_bnf, '[]');
	is_deeply($data, [], 'Expect parse to succeed');

	$data = run_test($user_bnf, <<'JSON');
	[
	      {
	         "precision": "zip",
	         "Latitude":  37.7668,
	         "Longitude": -122.3959,
	         "Address":   "",
	         "City":      "SAN FRANCISCO",
	         "State":     "CA",
	         "Zip":       "94107",
	         "Country":   "US"
	      },
	      {
	         "precision": "zip",
	         "Latitude":  37.371991,
	         "Longitude": -122.026020,
	         "Address":   "",
	         "City":      "SUNNYVALE",
	         "State":     "CA",
	         "Zip":       "94085",
	         "Country":   "US"
	      }
	]
JSON

	is_deeply($data, [
	    { "precision"=>"zip", Latitude => "37.7668", Longitude=>"-122.3959",
	      "Country" => "US", Zip => 94107, Address => '',
	      City => "SAN FRANCISCO", State => 'CA' },
	    { "precision" => "zip", Longitude => "-122.026020", Address => "",
	      City => "SUNNYVALE", Country => "US", Latitude => "37.371991",
	      Zip => 94085, State => "CA" }
	], 'Expect parse to succeed');

	$data = run_test($user_bnf, <<'JSON');
	{
	    "Image": {
	        "Width":  800,
	        "Height": 600,
	        "Title":  "View from 15th Floor",
	        "Thumbnail": {
	            "Url":    "http://www.example.com/image/481989943",
	            "Height": 125,
	            "Width":  "100"
	        },
	        "IDs": [116, 943, 234, 38793]
	    }
	}
JSON

	is_deeply($data, {
	    "Image" => {
	        "Width" => 800, "Height" => 600,
	        "Title" => "View from 15th Floor",
	        "Thumbnail" => {
	            "Url" => "http://www.example.com/image/481989943",
	            "Height" => 125,
	            "Width" => 100,
	        },
	        "IDs" => [ 116, 943, 234, 38793 ],
	    }
	}, 'Expect parse to succeed');

	$data = run_test($user_bnf, <<'JSON');
	{
	    "source" : "<a href=\"http://janetter.net/\" rel=\"nofollow\">Janetter</a>",
	    "entities" : {
	        "user_mentions" : [ {
	                "name" : "James Governor",
	                "screen_name" : "moankchips",
	                "indices" : [ 0, 10 ],
	                "id_str" : "61233",
	                "id" : 61233
	            } ],
	        "media" : [ ],
	        "hashtags" : [ ],
	        "urls" : [ ]
	    },
	    "in_reply_to_status_id_str" : "281400879465238529",
	    "geo" : {
	    },
	    "id_str" : "281405942321532929",
	    "in_reply_to_user_id" : 61233,
	    "text" : "@monkchips Ouch. Some regrets are harsher than others.",
	    "id" : 281405942321532929,
	    "in_reply_to_status_id" : 281400879465238529,
	    "created_at" : "Wed Dec 19 14:29:39 +0000 2012",
	    "in_reply_to_screen_name" : "monkchips",
	    "in_reply_to_user_id_str" : "61233",
	    "user" : {
	        "name" : "Sarah Bourne",
	        "screen_name" : "sarahebourne",
	        "protected" : false,
	        "id_str" : "16010789",
	        "profile_image_url_https" : "https://si0.twimg.com/profile_images/638441870/Snapshot-of-sb_normal.jpg",
	        "id" : 16010789,
	        "verified" : false
	    }
	}
JSON

	is_deeply($data, {
	    "source" => "<a href=\"http://janetter.net/\" rel=\"nofollow\">Janetter</a>",
	    "entities" => {
	        "user_mentions" => [ {
	                "name" => "James Governor",
	                "screen_name" => "moankchips",
	                "indices" => [ 0, 10 ],
	                "id_str" => "61233",
	                "id" => 61233
	            } ],
	        "media" => [ ],
	        "hashtags" => [ ],
	        "urls" => [ ]
	    },
	    "in_reply_to_status_id_str" => "281400879465238529",
	    "geo" => {
	    },
	    "id_str" => "281405942321532929",
	    "in_reply_to_user_id" => 61233,
	    "text" => "\@monkchips Ouch. Some regrets are harsher than others.",
	    "id" => 281405942321532929,
	    "in_reply_to_status_id" => 281400879465238529,
	    "created_at" => "Wed Dec 19 14:29:39 +0000 2012",
	    "in_reply_to_screen_name" => "monkchips",
	    "in_reply_to_user_id_str" => "61233",
	    "user" => {
	        "name" => "Sarah Bourne",
	        "screen_name" => "sarahebourne",
	        "protected" => '', # false.
	        "id_str" => "16010789",
	        "profile_image_url_https" => "https://si0.twimg.com/profile_images/638441870/Snapshot-of-sb_normal.jpg",
	        "id" => 16010789,
	        "verified" => '' # false.
	    }
	}, 'Expect parse to succeed');

	$data = run_test($user_bnf, <<'JSON');
	{ "test":  "\u2603" }
JSON

	is($$data{test}, "\x{2603}");

	TODO:
	{
		my($message) = "Marpa's SLIF doesn't understand higher than 8-bit codepoints yet";
		local $TODO  = $message;

		dies_ok {
		    $data = run_test($user_bnf, <<'JSON');
		{ "test":  "éáóüöï" }
JSON
		}, $message;
	}

} # End of run_tests;

# ------------------------------------------------

run_tests('data/json.1.bnf');

done_testing();