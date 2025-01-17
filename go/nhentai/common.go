package nhentai

import (
	"encoding/json"
	"nhentai/nhentai/database/cache"
	"time"
)

// PING

// @
// "104.27.195.88:443"

// t.nhentai.net
//185.177.127.78 (3115417422)
//185.177.127.77 (3115417421)
//23.237.126.122 (401440378)

// t5.nhentai.net
// 185.177.127.77 (3115417421)

// i.nhentai.net
//185.177.127.78 (3115417422)
//23.237.126.122 (401440378)
//185.177.127.77 (3115417421)

func availableWebAddresses(_ string) (string, error) {
	return serialize([]string{
		"104.27.194.88:443",
		"104.27.195.88:443",
	}, nil)
}

func availableImgAddresses(_ string) (string, error) {
	return serialize([]string{
		"23.237.126.122:443",
		"185.177.127.78:443",
		"185.177.127.77:443",
	}, nil)
}

func cacheable(key string, expire time.Duration, reload func() (interface{}, error)) (string, error) {
	// CACHE
	cacheable, err := cache.LoadCache(key, expire)
	if err != nil {
		return "", err
	}
	if cacheable != "" {
		return cacheable, nil
	}
	// RELOAD
	cacheable, err = serialize(reload())
	if err != nil {
		return "", err
	}
	// push to cache (if cache error )
	_ = cache.SaveCache(key, cacheable)
	// return
	return cacheable, nil
}

// 将interface序列化成字符串, 方便与flutter通信
func serialize(point interface{}, err error) (string, error) {
	if err != nil {
		return "", err
	}
	buff, err := json.Marshal(point)
	return string(buff), nil
}
