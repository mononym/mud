export interface LinkInterface {
  id: string;
  arrivalText: string;
  departureText: string;
  shortDescription: string;
  longDescription: string;
  type: string;
  icon: string;
  toId: string;
  fromId: string;
  localToX: number;
  localToY: number;
  localToCorners: number;
  localToSize: number;
  localToColor: string;
  localFromX: number;
  localFromY: number;
  localFromCorners: number;
  localFromSize: number;
  localFromColor: string;
}

const state: LinkInterface = {
  id: "",
  arrivalText: "",
  departureText: "",
  shortDescription: "",
  longDescription: "",
  icon: "fas-fa-compass",
  type: "Direction",
  toId: "",
  fromId: "",
  localFromX: 0,
  localFromY: 0,
  localFromCorners: 5,
  localFromSize: 21,
  localFromColor: "#008080",
  localToX: 0,
  localToY: 0,
  localToCorners: 5,
  localToSize: 21,
  localToColor: "#008080",
};

export default state;
