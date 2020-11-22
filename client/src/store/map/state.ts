export interface LabelInterface {
    id: string;
    x: number;
    y: number;
    text: string
    rotation: number
    color: string
    size: number
    inlineSize: number
    style: string
    weight: string
    family: string
  }

  const LabelState: LabelInterface =  {
  id: '',
  x: 0,
  y: 0,
  text: '',
  rotation: 0,
  color: '',
  size: 20,
  inlineSize: 200,
  style: 'normal',
  weight: 'normal',
  family: 'sans-sarif'
}

export {LabelState}

export interface MapInterface {
  id: string;
  description: string;
  name: string;
  viewSize: number;
  gridSize: number;
  labels: LabelInterface[]
  instanceId: string
}

const state: MapInterface = {
  id: '',
  description: '',
  name: '',
  viewSize: 5000,
  gridSize: 10,
  labels: [],
  instanceId: ''
};

export default state;
