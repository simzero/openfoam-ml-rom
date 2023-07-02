import jsfluids from '@simzero/jsfluids'
import fs from 'fs'
import yargs from 'yargs'
import ort from 'onnxruntime-node'

const argv = yargs(process.argv.splice(2))
  .option('grid', {
    alias: 'g',
    default: "internal.vtu"
  })
  .option('model', {
    alias: 'm',
    default: "model.onnx"
  })
  .option('output', {
    alias: 'o',
    default: "verification"
  })
  .option('cells-x', {
    alias: 'x',
    default: 100
  })
  .option('cells-y', {
    alias: 'y',
    default: 100
  })
  .option('stl', {
    alias: 's'
  })
  .help('h').argv;
  
const shapePosition = argv.dz;
const shapeRotation = argv.rotation;

(async () => {
  let startInitialize = new Date().getTime();
  
  const width = 4;
  const resolution = 100;

  await jsfluids.ready
  const model = jsfluids.ML;

  let primitive;

  const stlData = fs.readFileSync(argv.stl);
  const gridData = fs.readFileSync(argv.grid);

  await model.loadMesh(gridData);
  const onnx = await ort.InferenceSession.create(argv.model);

  const nCells = argv.x * argv.y;
  const inputArray = Float32Array.from(model.SDFAndRegion(stlData));
  const inputTensor = new ort.Tensor('float32', inputArray, [1, 3, argv.y, argv.x]);
  const feeds = { inputModel: inputTensor };
  const results = await onnx.run(feeds);

  const Uxy = results['outputModel'].data.slice(0, 2 * nCells);
  const U = new Float32Array(3 * nCells);
  U.set(Uxy.slice(0, nCells));
  U.fill(0, nCells, 2 * nCells);
  U.set(Uxy.slice(-nCells), 2 * nCells);

  const p = results['outputModel'].data.slice(-nCells);

  model.update({ field: "U", data: U });
  model.update({ field: "p", data: p });
  const dataString = model.grid();
  fs.writeFileSync(argv.output, dataString);
})();
