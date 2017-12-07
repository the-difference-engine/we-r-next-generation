def checkParameters(parameters, required)
  for reqs in required do
    if !parameters.include?(reqs)
      return false
    end
  end
  return parameters.length == required.length
end
