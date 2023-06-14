# this is some template to help mimicking unittest at compile time
# perhaps we can implement a real compile time unittest?

template ctCheck*(cond: untyped) =
  doAssert(cond)

template ctTest*(name: string, body: untyped) =
  block:
    body
    echo "[OK] compile time ", name

template ctExpect*(errTypes, body: untyped) =
  try:
    body
  except errTypes:
    discard
  except CatchableError:
    doAssert(false, "unexpected error")
  except Defect:
    doAssert(false, "unexpected defect")