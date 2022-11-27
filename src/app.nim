import prologue
import std/strformat
import std/sha1
import std/os

# Doesn't work for some reason
# import prologue/middlewares/staticfile

# TODO: Implement authentication
# import prologue/middlewares/auth
import dotenv
load() # Loads the .env file into the sys variables


proc hello*(ctx: Context) {.async.} =
  resp "<h1>No, you <strong>won't</strong> find easter eggs here.</h1>"

proc upload(ctx: Context) {.async.} =
  if ctx.request.reqMethod == HttpGet:
    await ctx.staticFileResponse("static/uploader.html", "")
  elif ctx.request.reqMethod == HttpPost:
    
    let file = ctx.getFormParamsOption("file").get()

    let hash = secureHash(file)
    let domain_name = getEnv("NFU_DOMAIN_NAME")
    
    writeFile(fmt"files/{hash}", file)
    resp fmt"{domain_name}files/{hash}"

proc staticServe(ctx: Context) {.async.} =
  let file_name = ctx.getPathParams("filename")
  await ctx.staticFileResponse(fmt"files/{filename}", "")

let app = newApp()
app.get("/", hello)
app.addRoute("/upload", upload, @[HttpGet, HttpPost])
#FIXME: figure out a way to replace this \/ with something better
app.addRoute("/files/{filename}", staticServe, HttpGet)
app.run()