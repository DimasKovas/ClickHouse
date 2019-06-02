SET send_logs_level = 'none';

CREATE TABLE delta_codec_for_alter (date Date, x UInt32 Codec(Delta), s FixedString(128)) ENGINE = MergeTree ORDER BY tuple();
SELECT compression_codec FROM system.columns WHERE database = 'default' AND table = 'delta_codec_for_alter' AND name = 'x';
ALTER TABLE delta_codec_for_alter MODIFY COLUMN x Codec(Delta, LZ4);
SELECT compression_codec FROM system.columns WHERE database = 'default' AND table = 'delta_codec_for_alter' AND name = 'x';
ALTER TABLE delta_codec_for_alter MODIFY COLUMN x UInt64 Codec(Delta, LZ4);
SELECT compression_codec FROM system.columns WHERE database = 'default' AND table = 'delta_codec_for_alter' AND name = 'x';
