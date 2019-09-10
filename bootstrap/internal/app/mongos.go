package app

import (
	"fmt"
	"time"

	"github.com/pkg/errors"
	"gopkg.in/mgo.v2"
	"gopkg.in/mgo.v2/bson"
)

type Mongos struct {
	Address        string
	ReplicaSetUrls []string
}

func (m *Mongos) Init() error {
	session, err := mgo.DialWithTimeout(fmt.Sprintf(
		"%v?connect=direct", m.Address), 5*time.Second)
	if err != nil {
		return errors.Wrapf(err, "%v connection failed", m.Address)
	}

	defer session.Close()
	session.SetMode(mgo.Monotonic, true)

	for _, replicaSet := range m.ReplicaSetUrls {
		result := bson.M{}
		if err := session.Run(bson.M{"addShard": replicaSet}, &result); err != nil {
			return errors.Wrapf(err, "%v addShard failed", m.Address)
		}
	}
	return nil
}
