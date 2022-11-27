import prologue
import std/strformat
import std/sha1


proc hello*(ctx: Context) {.async.} =
  resp "<h1>No, you <strong>won't</strong> find easter eggs here.</h1>"

proc upload(ctx: Context) {.async.} =
  if ctx.request.reqMethod == HttpGet:
    await ctx.staticFileResponse("static/uploader.html", "")
  elif ctx.request.reqMethod == HttpPost:

    let file = ctx.getUploadFile("file")
    let hash = secureHash(file.filename)

    file.save("files/", fmt"{hash}")
    resp fmt"<html><h1>{file.filename}</h1><p>{file.body}</p></html>"

let app = newApp()
app.get("/", hello)
app.addRoute("/upload", upload, @[HttpGet, HttpPost])

app.run()