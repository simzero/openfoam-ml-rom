// Copyright (c) 2022 Carlos Peña-Monferrer. All rights reserved.
// This work is licensed under the terms of the GNU LGPL v3.0 license.
// For a copy, see <https://opensource.org/licenses/LGPL-3.0>.

import rom from '@simzero/rom'
import Papa from 'papaparse'
import fs from 'fs'
import yargs from 'yargs'
import jszip from 'jszip'

const argv = yargs(process.argv.splice(2))
  .option('name', {
    alias: 'n',
    default: "case"
  })
  .option('surrogatePath', {
    alias: 's',
    default: "surrogates"
  })
  .option('outputPath', {
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

const loadData = async (zipFiles, filename) => {
  const item = zipFiles.files[filename];
  const buffer = Buffer.from(await item.async('arraybuffer'));
  const data = await readFile(buffer);
  const transposed = data[0].map((col, i) => data.map(row => row[i]));
  const transposedBuffer = Float64Array.from(transposed.flat());

  return [transposedBuffer, data.length, data[0].length];
}

const readFile = async (buffer) => {
  const csvData = buffer.toString();

  return new Promise(resolve => {
    Papa.parse(csvData, {
      delimiter: ' ',
      dynamicTyping: true,
      skipEmptyLines: true,
      header: false,
      complete: results => {
        resolve(results.data);
      }
    });
  });
};

(async () => {
  let startInitialize = new Date().getTime();

  const zipContent = fs.readFileSync(argv.surrogatePath);
  const zipFiles = await jszip.loadAsync(zipContent);

  await rom.ready

  const nBC = 2;

  const KData = await loadData(zipFiles, 'K_mat.txt');
  const BData = await loadData(zipFiles, 'B_mat.txt');
  const modesData = await loadData(zipFiles, 'EigenModes_U_mat.txt');
  const coeffL2Data = await loadData(zipFiles, 'coeffL2_mat.txt');
  const muData = await loadData(zipFiles, 'par.txt');
  const gridItem = zipFiles.files['internal.vtu'];
  const gridData = Buffer.from(await gridItem.async('arraybuffer'));

  const nPhiU = BData[1];
  const nPhiP = KData[2];
  const nPhiNut = coeffL2Data[1];
  const nRuns = coeffL2Data[2];

  const reduced = new rom.reducedSteady(nPhiU + nPhiP, nPhiU + nPhiP);

  reduced.stabilization(argv.stabilization);
  reduced.nPhiU(nPhiU);
  reduced.nPhiP(nPhiP);
  reduced.nPhiNut(nPhiNut);
  reduced.nRuns(nRuns);
  reduced.nBC(nBC);
  reduced.readUnstructuredGrid(gridData);
  reduced.initialize();

  const K = reduced.K();
  const B = reduced.B();

  K.set(KData[0]);
  B.set(BData[0]);

  if (argv.stabilization == 'supremizer') {
    const PData = await loadData(zipFiles, 'P_mat.txt');
    const P = reduced.P();

    P.set(PData[0]);
  }
  else if (argv.stabilization == 'PPE') {
    const DData = await loadData(zipFiles, 'D_mat.txt');
    const BC3Data = await loadData(zipFiles, 'BC3_mat.txt');
    const D = reduced.D();
    const BC3 = reduced.BC3();

    D.set(DData[0]);
    BC3.set(BC3Data[0]);
  }
  else {
    // TODO: check
  }

  const modes = reduced.modes();
  modes.set(modesData[0]);

  reduced.nu(argv.nu);

  for (let i = 0; i < nPhiNut; i ++ ) {
    const weightsData = await loadData(zipFiles, 'wRBF_' + i + '_mat.txt');
    const weights = reduced.weights();

    weights.set(weightsData[0]);
    reduced.addWeights();
  }

  for (let i = 0; i < nPhiU; i ++ ) {
    const CData = await loadData(zipFiles, 'C' + i + '_mat.txt');
    const Ct1Data = await loadData(zipFiles, 'ct1_' + i + '_mat.txt');
    const Ct2Data = await loadData(zipFiles, 'ct2_' + i + '_mat.txt');
    const C = reduced.C();
    const Ct1 = reduced.Ct1();
    const Ct2 = reduced.Ct2();

    C.set(CData[0]);
    reduced.addCMatrix();
    Ct1.set(Ct1Data[0]);
    reduced.addCt1Matrix();
    Ct2.set(Ct2Data[0]);
    reduced.addCt2Matrix();
  }

  if (argv.stabilization == 'PPE') {
    for (let i = 0; i < nPhiP; i ++ ) {
      const GData = await loadData(zipFiles, 'G' + i + '_mat.txt');
      const G = reduced.G();

      G.set(GData[0]);
      reduced.addGMatrix();
    }
  }

  const mu = reduced.mu();
  const coeffL2 = reduced.coeffL2();

  mu.set(muData[0]);
  coeffL2.set(coeffL2Data[0]);
  reduced.setRBF();

  const endInitialize = new Date().getTime();
  const timeInitialize = endInitialize - startInitialize;

  const startSolve = new Date().getTime();
  reduced.solveOnline(argv.Ux, argv.Uy);
  reduced.reconstruct();
  const endSolve = new Date().getTime();
  const timeSolve = endSolve - startSolve;

  const dataString = reduced.exportUnstructuredGrid();

  fs.writeFileSync(argv.outputPath, dataString);

  console.log('Execution time initialize: ' + 0.001*timeInitialize + " s.");
  console.log('Execution time solve and reconstruct: ' + 0.001*timeSolve + " s.");

  reduced.delete();
})();
