resource "aws_api_gateway_method" "lambda" {
  rest_api_id        = var.api_gateway_id
  resource_id        = var.resource_id
  http_method        = var.method
  authorization      = var.authorization != "NONE" ? "CUSTOM" : "NONE"
  authorizer_id      = var.authorization != "NONE" ? var.authorizer_id : null
  request_models     = var.request_models
  request_parameters = var.request_parameters_integration
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id             = var.api_gateway_id
  resource_id             = var.resource_id
  http_method             = var.method
  integration_http_method = var.method
  type                    = "AWS"
  uri                     = var.uri_origin
  passthrough_behavior    = "WHEN_NO_MATCH"

  request_templates = {
    "application/json" = <<EOF
#set( $body = $input.json("$") )

#define( $loop )
  {
  #foreach($key in $map.keySet())
      #set( $k = $util.escapeJavaScript($key) )
      #set( $v = $util.escapeJavaScript($map.get($key)).replaceAll("\\'", "'") )
      "$k":
        "$v"
        #if( $foreach.hasNext ) , #end
  #end
  }
#end

{
  "body": "$util.escapeJavaScript($input.json('$'))",
  "method": "$context.httpMethod",
  "principalId": "$context.authorizer.principalId",
  "stage": "$context.stage",
  "headers": {
    "Apigtw-Request-Id" : "$context.requestId",
    "Escale-User-Id": "$context.authorizer.principalId",
    "Partner": "$context.authorizer.brand",
    "Product": "$context.authorizer.product",
    #foreach($param in $input.params().header.keySet())
    "$param": "$util.escapeJavaScript($input.params().header.get($param))"
    #if($foreach.hasNext),#end
    #end
  },

  "cognitoPoolClaims" : {
    
    "sub": "$context.authorizer.claims.sub"
  },

  "requestContext": {
    "requestId": "$context.requestId"
  },

  #set( $map = $context.authorizer )
  "enhancedAuthContext": $loop,

  #set( $map = $input.params().querystring )
  "query": $loop,

  #set( $map = $input.params().path )
  "pathParameters": $loop,

  #set( $map = $context.identity )
  "identity": $loop,

  #set( $map = $stageVariables )
  "stageVariables": $loop,

  "requestPath": "$context.resourcePath"
}
EOF
  }
}