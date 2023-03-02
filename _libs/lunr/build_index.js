var path    = require("path");
var fs      = require("fs");
var lunr    = require("lunr");
var cheerio = require("cheerio");

// don't modify this, it'll be modified on the fly by lunr() in Franklin
const PATH_PREPEND = "..";

const HTML_FOLDER  = "../../__site";
const OUTPUT_INDEX = "lunr_index.js";

function isHtml(filename) {
    lower = filename.toLowerCase();
    return (lower.endsWith(".htm") || lower.endsWith(".html"));
}

function findHtml(folder) {
    if (!fs.existsSync(folder)) {
        console.log("Could not find folder: ", folder);
        return;
    }
    var files = fs.readdirSync(folder);
    var htmls = [];
    for (var i = 0; i < files.length; i++) {
        var filename = path.join(folder, files[i]);
        var stat = fs.lstatSync(filename);
        if (stat.isDirectory()) {
            if (stat == "assets" || stat == "css" || stat == "libs" ) {
                continue
            }
            var recursed = findHtml(filename);
            for (var j = 0; j < recursed.length; j++) {
                recursed[j] = path.join(files[i], recursed[j]).replace(/\\/g, "/");
            }
            htmls.push.apply(htmls, recursed);
        }
        else if (isHtml(filename)){
            htmls.push(files[i]);
        };
    };
    return htmls;
};

function readHtml(root, file, fileId) {
    var filename = path.join(root, file);
    var txt = fs.readFileSync(filename).toString();
    var $ = cheerio.load(txt);
    var title = $("title").text();
    if (typeof title == 'undefined') title = file;
    var body = $("body").text()
    if (typeof body == 'undefined') body = "";

    var data = {
        "id": fileId,
        "l": filename,
        "t": title,
        "b": body
    }
    return data;
}


function readHtmlModified(root, file, fileId) {
    var filename = path.join(root, file);
    var txt = fs.readFileSync(filename).toString();
    var $ = cheerio.load(txt);
    //var title = $("title").text();
    var h3 = $("h3", ".reference");
    

    var list = [];
    var i = 0;
    h3.each(function (index, element) {
        var title = $(element).text();
        var body = $('ul', $(element).parent()).text();
        if (body) {
            body = body.replace(/[\r\n]/gm, '');
            body = body.replace('Authors:', 'by');
            body = body.replace('Published in:', ' in ');
            body = body.replace(/(?<=DOI:).*/gm, '');
            body = body.replace('DOI:', '');
        }
        // node id
        var tid = $(element).attr("id");
        var data = {
            "id": fileId + i,
            "l": filename,
            "t": title,
            "b": body === undefined ? "": body,
            "tid": tid
        }
        list.push(data)
        i += 1;
    });

    return list;
}

function buildIndex(docs) {
    var idx = lunr(function () {
        this.ref('id');
        this.field('t'); // title
        this.field('b'); // body
        docs.forEach(function (doc) {
                this.add(doc);
            }, this);
        });
    return idx;
}

function buildPreviews(docs) {
    var result = {};
    for (var i = 0; i < docs.length; i++) {
        var doc = docs[i];
        result[doc["id"]] = {
            "t": doc["t"],
            "tid": doc["tid"],
            "b": doc["b"],
            "l": doc["l"].replace(/^\.\.\/\.\.\/__site/gi, '/' + PATH_PREPEND)
        }
    }
    return result;
}

function main() {
    files = findHtml(HTML_FOLDER);
    var docs = [];
    var id = 1;
    for (var i = 0; i < files.length; i++) {
        var data = readHtmlModified(HTML_FOLDER, files[i], id)
        id += data.length;
        for (var j = 0; j < data.length; j++) {
            if (data[j] == undefined) {
                continue;
            }

            docs.push(data[j]);
        }
    }
    var idx  = buildIndex(docs);
    var prev = buildPreviews(docs);
    var js = "const LUNR_DATA = " + JSON.stringify(idx) + ";\n" +
             "const PREVIEW_LOOKUP = " + JSON.stringify(prev) + ";";
    fs.writeFile(OUTPUT_INDEX, js, function(err) {
        if(err) {
            return console.log(err);
        }
    });
}

main();
