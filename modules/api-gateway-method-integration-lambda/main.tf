resource "aws_api_gateway_method" "lambda" {
  rest_api_id        = data.aws_api_gateway_rest_api.gateway_api.id
  resource_id        = var.resource_id
  http_method        = var.method
  authorization      = var.authorization != "NONE" ? "CUSTOM" : "NONE"
  authorizer_id      = var.authorization != "NONE" ? var.authorizer_id : null
}

resource "aws_lambda_permission" "lambda" {
  statement_id  = "AllowAPIGatewayEscaleInvoke_${var.api_gateway}_${var.resource_id}"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "apigateway.amazonaws.com"

  # The /*/* portion grants access from any method on any resource
  # within the API Gateway "REST API".
  source_arn = "${data.aws_api_gateway_rest_api.gateway_api.execution_arn}/*/*"
}


resource "aws_api_gateway_integration" "lambda" {
  depends_on = [ aws_api_gateway_method.lambda ]

  rest_api_id             = data.aws_api_gateway_rest_api.gateway_api.id
  resource_id             = var.resource_id
  http_method             = var.method
  integration_http_method = "POST"
  type                    = "AWS"
  uri                     = "arn:aws:apigateway:us-east-1:lambda:path/2015-03-31/functions/${var.lambda_arn}/invocations"
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

resource "aws_api_gateway_method_response" "response_200" {
  depends_on = [ aws_api_gateway_integration.lambda ]
  rest_api_id = data.aws_api_gateway_rest_api.gateway_api.id
  resource_id = var.resource_id
  http_method = var.method
  status_code = "200"

}

resource "aws_api_gateway_integration_response" "lambda" {
  depends_on = [ aws_api_gateway_integration.lambda ]
  
  rest_api_id = data.aws_api_gateway_rest_api.gateway_api.id
  resource_id = var.resource_id
  http_method = var.method
  status_code = "200"

  response_templates = { 
    "application/json" = <<EOF
#set($elem = $util.parseJson($input.json('$')))
$elem.get("body")
#set($context.responseOverride.status = $elem.get("statusCode"))
EOF
  }
}
