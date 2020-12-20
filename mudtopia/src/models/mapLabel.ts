export interface MapLabelInterface {
  id: string;
  x: number;
  y: number;
  text: string;
  rotation: number;
  color: string;
  size: number;
  style: string;
  weight: string;
  family: string;
  verticalOffset: number;
  horizontalOffset: number;
}

const state: MapLabelInterface = {
  id: "",
  x: 0,
  y: 0,
  text: "",
  rotation: 0,
  color: "#FFFFFF",
  size: 20,
  style: "normal",
  weight: "normal",
  family: "sans-sarif",
  verticalOffset: 0,
  horizontalOffset: 0,
};

export default state;
