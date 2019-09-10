package app

import (
	"fmt"
	"time"

	"github.com/pkg/errors"
	"gopkg.in/mgo.v2"

	"github.com/netSkope/service/libs/common/go/logging"
)

func ping(member string) error {
	session, err := mgo.DialWithTimeout(fmt.Sprintf(
		"%v?connect=direct", member), 5*time.Second)
	if err != nil {
		return errors.Wrap(err, "Connection failed")
	}

	defer session.Close()
	session.SetMode(mgo.Monotonic, true)

	err = session.Ping()
	return errors.Wrap(err, "Connection failed")
}

func pingWithRetry(member string, retry int, wait int) error {
	var err error
	for retry > 0 {
		err = ping(member)
		if err != nil {
			retry--
			logging.GetLogger().Warnf("%v is offline retrying in %v seconds", member, wait)
			time.Sleep(time.Duration(wait) * time.Second)
		} else {
			return nil
		}
	}

	return errors.Wrapf(err, "%v ping failed", member)
}
