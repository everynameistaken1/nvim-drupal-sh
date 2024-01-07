local Q = {}

Q.ConstructorExists = [[
 (method_declaration)
  (visibility_modifier)
  name: (name) @methodName (#eq? @methodName "__construct")
]]

Q.CapturePromotingParamsInConstructor = [[
(
 (method_declaration
  name: (name) @methodName (#eq? @methodName "__construct")
  parameters: (formal_parameters
   (property_promotion_parameter) @promParam
  )
 )
) @res
]]

return Q
