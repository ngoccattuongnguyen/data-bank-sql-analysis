# Data Bank: Assumptions & Data Notes

## Dữ liệu
- customer_transactions: 5,868 dòng
- customer_nodes: 3,500 dòng, 500 khách (trung bình 7 lần phân node/khách, tức ~6 lần đổi node)
- customer_id cố định, mỗi lần đổi node tạo thêm 1 dòng mới
- Region 5 trong data là "Australia", tài liệu đề bài ghi "Oceania". Dùng tên theo data.

## Khoảng thời gian
- Giao dịch: 2020-01-01 đến 2020-04-28 (tháng 4 thiếu 2 ngày)
- Node: đến 2020-07-02 (không trùng khoảng thời gian với giao dịch)

## Quyết định xử lý
- end_date = 9999-12-31 (500 dòng, 1 dòng/khách) là node hiện tại, chưa kết thúc. Loại khỏi tính số ngày reallocation (A4, A5).

## Phần A - Kết quả
- A1: 25 node (5 node x 5 region). node_id 1-5 lặp lại ở mỗi region, cùng id nhưng là node khác nhau.
- A2: Mỗi region có 5 node, phân bổ đều.
- A3: Australia 110, America 105, Africa 102, Asia 95, Europe 88. Tổng 500 → mỗi khách chỉ thuộc 1 region.
- A4: Trung bình 14.6 ngày/lần chuyển node.
- A5: Median 15, p80 23-24, p95 28 ngày. Đồng nhất giữa 5 region.

## Phần B - Kết quả
- B1: Deposit 2,671 GD / 1,359,168; Purchase 1,617 / 806,537; Withdrawal 1,580 / 793,003.
- Tổng tiền ra > tiền vào ~240K → nhiều khách có số dư âm.
- Mỗi loại GD trung bình ~500, phân bố đều → dữ liệu giả lập.
- B2: TB mỗi khách 5.3 lần deposit, tổng 2,718.3 (tính tổng theo khách rồi lấy TB). ~1.3 lần deposit/tháng.
- B3: "either 1 purchase or 1 withdrawal" hiểu là ít nhất 1. Kết quả: T1 168, T2 181, T3 192, T4 70 khách.
- B4: Chỉ hiển thị tháng có giao dịch. Bản đủ 4 tháng ở C2.
- B5: So sánh số dư cuối tháng 1 với số dư cuối kỳ. Chỉ xét khách có số dư tháng 1 > 0, mẫu số 500 khách. Kết quả: 23.4%.

## Phần C - Assumptions
- 1 đơn vị tiền = 1 đơn vị data.
- Số dư âm được cấp 0 data.
- Giao dịch cùng ngày không có giờ/ID nên thứ tự trong ngày không xác định. Số dư cuối ngày vẫn chính xác.
- C2: Tháng không có giao dịch, số dư giữ nguyên tháng trước. Mỗi khách đủ 4 tháng, 2,000 dòng.
- Option 1: data tháng M = tổng số dư dương cuối tháng M-1.
- Option 2: dùng trung bình số dư sau các giao dịch trong tháng làm xấp xỉ cho trung bình 30 ngày.
- Option 3: cần đủ data cho số dư CAO NHẤT của khách trong tháng.
- Option 2, 3: tháng không có giao dịch không được tính.

## Phần C - Kết quả (data cần cấp cho mỗi tháng)
| Tháng | Option 1 | Option 2 | Option 3 |
|---|---|---|---|
| Tháng 1 | n/a | 222,190 | 363,998 |
| Tháng 2 | 235,595 | 230,257 | 353,655 |
| Tháng 3 | 261,508 | 235,619 | 353,231 |
| Tháng 4 | 260,971 | 152,071* | 188,025* |

*Khách hoạt động: T1 500, T2 455, T3 456, T4 309. Tháng 4 giảm 32% số khách, giải thích phần lớn mức giảm data tháng 4 (Option 2 −35%, Option 3 −47%). Chỉ so sánh tháng 2-3.

## Insight
- Dữ liệu khách được chuyển node trung bình mỗi 2 tuần, 95% không quá 28 ngày, đồng nhất mọi region.
- Real-time cần nhiều hơn 35-50% dung lượng so với Option 1. Option 2 thấp hơn Option 1 khoảng 2-10%.
