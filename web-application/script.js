const fs = require("fs");

let dropbox = document.getElementById("dropbox");
["dragenter", "dragover", "dragleave", "drop"].forEach((eventName) => {
  dropbox.addEventListener(eventName, preventDefaults, false);
  document.body.addEventListener(eventName, preventDefaults, false);
});

["dragenter", "dragover"].forEach((eventName) => {
  dropbox.addEventListener(eventName, highlight, false);
});
["dragleave", "drop"].forEach((eventName) => {
  dropbox.addEventListener(eventName, unhighlight, false);
});

dropbox.addEventListener("drop", handleDrop, false);

function preventDefaults(e) {
  e.preventDefault();
  e.stopPropagation();
}

function highlight(e) {
  dropbox.classList.add("highlight");
}

function unhighlight(e) {
  dropbox.classList.remove("highlight");
}

function handleDrop(e) {
  var dt = e.dataTransfer;
  var files = dt.files;
  handleFiles(files);
}

function handleFiles(files) {
  [...files].forEach(previewFile);
}
function loadImage() {
  const name = document.getElementById("imgName").value;
  console.log(name);
  const files = fs.readdirSync("/images/");
  console.log("Got files", files);
  // addImage(url);
}

function addImage(name) {
  if (name === "") {
    alert("You should enter a name");
    return;
  }
  let img = document.createElement("img");
  img.src = src;
  const parentNode = document.getElementById("preview");
  if (parentNode.children[0] != null) {
    parentNode.removeChild(parentNode.children[0]);
  }
  parentNode.appendChild(img);
}

function previewFile(file) {
  let reader = new FileReader();
  reader.readAsDataURL(file);
  reader.onloadend = () => {
    let img = document.createElement("img");
    img.src = reader.result;
    const parentNode = document.getElementById("preview");
    if (parentNode.children[0] != null) {
      parentNode.removeChild(parentNode.children[0]);
    }
    parentNode.appendChild(img);
  };
}
