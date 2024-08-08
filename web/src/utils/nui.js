
const nuiMessage = async function (eventName, data = {}) {
  const options = {
    method: "post",
    headers: {
      "Content-Type": "application/json; charset=UTF-8",
    },
    body: JSON.stringify(data),
  };

  const resourceName = "devyn_shops";

  try {
    const resp = await fetch(`https://${resourceName}/${eventName}`, options);
    return await resp.json();
  } catch(err) {
    console.log(err);
  };
};

export default nuiMessage;