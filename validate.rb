def checkParameters(parameters, required)
  i = 0
  for reqs in required
    if !parameters.include?(reqs)
      return false
    end
  end
  return parameters.length == required.length
end
