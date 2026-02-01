<!DOCTYPE html>
<html lang="ja">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>料金比較ツール</title>
<link href="https://fonts.googleapis.com/css2?family=Zen+Maru+Gothic&family=Inter:wght@400;600&display=swap" rel="stylesheet">
<style>
  body { font-family: "Zen Maru Gothic", sans-serif; background: #fafafa; margin: 12px; }
  h1 { text-align: center; color: #c7000b; margin-bottom: 6px; }
  .note { text-align: center; font-size: 12px; color: #666; margin-bottom: 16px; }
  .row { display: grid; grid-template-columns: 1fr 1.2fr 1fr; gap: 10px; margin-bottom: 6px; }
  .cell { background: #ffffff; border: 1px solid #ddd; border-radius: 8px; height: 40px; display: flex; align-items: center; justify-content: center; box-sizing: border-box; padding: 0 8px; font-size: 14px; }
  .cell input, .cell select { width: 100%; height: 100%; border: none; background: transparent; outline: none; font-size: 14px; font-family: "Inter", sans-serif; text-align: center; }
  .header { background: #fff0f0; font-weight: bold; color: #c7000b; }
  .money { font-family: "Inter", sans-serif; font-weight: 600; }
  .final { background: #fff5f5; border: 2px solid #c7000b; color: #c7000b; font-weight: bold; }
  .diff { text-align: center; font-size: 20px; font-weight: bold; color: #c7000b; margin-top: 16px; min-height: 1.5em; }
  .price-cell { position: relative; }
  .yen { position: absolute; right: 8px; font-size: 12px; color: #666; pointer-events: none; }
</style>
</head>
<body>

<h1>料金比較ツール</h1>
<div class="note">※お客様と一緒に条件を選択してください</div>

<div class="row">
  <div class="cell header">ポイ活MAX</div>
  <div class="cell header">項目</div>
  <div class="cell header"><input type="text" placeholder="プラン名"></div>
</div>

<div class="row">
  <div class="cell money">11,748円</div>
  <div class="cell">基本料金</div>
  <div class="cell price-cell"><input type="number" id="r-base" placeholder="0"><span class="yen">円</span></div>
</div>

<div class="row">
  <div class="cell"><select class="l-disc"><option value="0">ー</option><option value="550">550円</option><option value="1210">1,210円</option></select></div>
  <div class="cell">みんなドコモ割</div>
  <div class="cell"><select class="r-disc"><option value="0">ー</option><option value="550">550円</option><option value="1210">1,210円</option></select></div>
</div>

<div class="row">
  <div class="cell"><select class="l-disc"><option value="0">ー</option><option value="110">110円</option><option value="220">220円</option></select></div>
  <div class="cell">長期利用割</div>
  <div class="cell"><select class="r-disc"><option value="0">ー</option><option value="110">110円</option><option value="220">220円</option></select></div>
</div>

<div class="row">
  <div class="cell"><select class="l-disc"><option value="0">ー</option><option value="1210">1,210円</option></select></div>
  <div class="cell">光セット割</div>
  <div class="cell"><select class="r-disc"><option value="0">ー</option><option value="1210">1,210円</option></select></div>
</div>

<div class="row">
  <div class="cell price-cell"><input type="number" id="l-other" placeholder="0"><span class="yen">円</span></div>
  <div class="cell">その他割引</div>
  <div class="cell price-cell"><input type="number" id="r-other" placeholder="0"><span class="yen">円</span></div>
</div>

<div class="row">
  <div class="cell" id="l-after">0円</div>
  <div class="cell">割引後料金</div>
  <div class="cell" id="r-after">0円</div>
</div>

<div class="row">
  <div class="cell price-cell"><input type="number" id="l-point" placeholder="0"><span class="yen">pt</span></div>
  <div class="cell">ポイ活特典</div>
  <div class="cell">ー</div>
</div>

<div class="row">
  <div class="cell final" id="l-final">0円</div>
  <div class="cell">実質料金</div>
  <div class="cell final" id="r-final">0円</div>
</div>

<div class="diff" id="diff">差額：—</div>

<script>
function calc() {
  const leftBase = 11748;
  const rightBase = Number(document.getElementById("r-base").value) || 0;

  // 割引の合算 (classを使って取得)
  let lDiscTotal = 0;
  document.querySelectorAll(".l-disc").forEach(s => lDiscTotal += Number(s.value));
  lDiscTotal += Number(document.getElementById("l-other").value) || 0;

  let rDiscTotal = 0;
  document.querySelectorAll(".r-disc").forEach(s => rDiscTotal += Number(s.value));
  rDiscTotal += Number(document.getElementById("r-other").value) || 0;

  // 割引後
  const lAfter = leftBase - lDiscTotal;
  const rAfter = rightBase - rDiscTotal;
  document.getElementById("l-after").textContent = lAfter.toLocaleString() + "円";
  document.getElementById("r-after").textContent = rAfter.toLocaleString() + "円";

  // 実質 (ポイント引き)
  const lPoint = Number(document.getElementById("l-point").value) || 0;
  const lFinal = lAfter - lPoint;
  const rFinal = rAfter; // 右側はポイント特典なし

  document.getElementById("l-final").textContent = lFinal.toLocaleString() + "円";
  document.getElementById("r-final").textContent = rFinal.toLocaleString() + "円";

  // 差額
  const diff = rFinal - lFinal; // 右 - 左 でプラスなら左がお得
  const diffText = document.getElementById("diff");
  if (rightBase === 0) {
    diffText.textContent = "比較対象を入力してください";
  } else if (diff > 0) {
    diffText.textContent = `ポイ活MAXの方が ${diff.toLocaleString()}円 お得🉐`;
  } else if (diff < 0) {
    diffText.textContent = `右のプランの方が ${Math.abs(diff).toLocaleString()}円 お得`;
  } else {
    diffText.textContent = "実質料金は同額です";
  }
}

// すべての入力変更を監視
document.addEventListener("input", calc);
document.addEventListener("change", calc);
</script>

</body>
</html>
