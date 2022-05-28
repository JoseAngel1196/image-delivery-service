// Global Parameters
const webUrl = "http://localhost:8080/images";
const apiUrl = "http://localhost:5000";
const searchedImageEl = document.getElementById("searchedImage");
const imgNotAvailableEl = document.getElementById("imgNotAvailable");
const searchElementBtn = document.getElementById("searchImage");
const imageNameInput = document.getElementById("imageName");

function initialize() {
  searchedImageEl.style.display = "none";
  imgNotAvailableEl.style.display = "none";
  searchElementBtn.addEventListener("click", searchImage);
}

const request = async (imageNameVal) => {
  return new Promise((resolve, reject) => {
    fetch(`${apiUrl}/${imageNameVal}`)
      .then((resp) => resolve(resp.json()))
      .catch((err) => reject(err));
  });
};

const searchImage = async () => {
  initialize();
  const imageNameValue = imageNameInput.value;

  if (imageNameValue == "") return;

  const response = await request(imageNameValue);
  const imageName = response["image_name"];
  console.log("Got imageName", imageName);

  if (!Boolean(imageName)) {
    imgNotAvailableEl.style.display = "block";
    return;
  }

  const imgSrc = `${webUrl}/${imageName}`;
  searchedImageEl.src = imgSrc;
  searchedImageEl.style.display = "block";
};

initialize();
