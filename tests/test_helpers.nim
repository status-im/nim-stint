# this is some template to help mimicking unittest at compile time
# perhaps we can implement a real compile time unittest?

template ctCheck*(cond: untyped) =
  doAssert(cond)

template ctTest*(name: string, body: untyped) =
  body
  echo "[OK] compile time ", name
