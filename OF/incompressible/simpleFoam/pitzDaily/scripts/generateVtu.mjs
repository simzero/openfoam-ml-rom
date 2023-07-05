import jsfluids from '@simzero/jsfluids'
import Papa from 'papaparse'
import fs from 'fs'
import yargs from 'yargs'
import jszip from 'jszip'

const argv = yargs(process.argv.splice(2))
  .option('grid', {
    alias: 'g',
    default: "internal.vtu"
  })
  .option('model', {
    alias: 'm',
    default: "model.zip"
  })
  .option('output', {
    alias: 'o',
    default: "verification"
  })
  .option('Ux', {
    default: 3.0
  })
  .option('Uy', {
    default: 0.0
  })
  .option('nu', {
    default: 1e-05
  })
  .option('stabilization', {
    alias: 'e',
    describe: 'choose a stabilization method',
    choices: ['supremizer', 'PPE']
  })
  .help('h').argv;

if(!argv.stabilization) {
  if (fs.existsSync(argv.surrogatePath + "D_mat.txt")) {
    argv.stabilization = "PPE";
  }
  else {
    argv.stabilization = "supremizer";
  }
}

(async () => {
  const gridData = fs.readFileSync(argv.grid);
  const zipContent = fs.readFileSync(argv.model);
  const zipFiles = await jszip.loadAsync(zipContent);

  await jsfluids.ready

  const model = jsfluids.ITHACAFV;

  await model.loadMesh(gridData);
  await model.loadModel(zipContent);
  model.update({ nu: argv.nu, U: [argv.Ux, argv.Uy] });
  const dataString = model.grid();
  fs.writeFileSync(argv.output, dataString);
})();
