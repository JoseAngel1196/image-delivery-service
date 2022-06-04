// Global Parameters
const webUrl = "PUBLIC_FACING_URL/images";
const apiUrl = "PUBLIC_FACING_URL/api";
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
    fetch(`${apiUrl}/image/${imageNameVal}`)
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
